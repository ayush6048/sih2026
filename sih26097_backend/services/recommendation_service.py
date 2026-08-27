import json
import os
from pydantic import BaseModel
from typing import List, Optional

class UserProfile(BaseModel):
    education: Optional[str] = None
    occupation: Optional[str] = None
    skills: List[str] = []
    interests: List[str] = []
    location: Optional[str] = None
    career_goal: Optional[str] = None

class RecommendationService:
    def __init__(self):
        # Load datasets
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        with open(os.path.join(base_dir, 'data', 'careers.json'), 'r') as f:
            self.careers = json.load(f)
        with open(os.path.join(base_dir, 'data', 'training.json'), 'r') as f:
            self.trainings = json.load(f)
            
        self.synonyms = {
            "machine work": "machine",
            "machine repair": "machine",
            "machine maintenance": "machine",
            "equipment repair": "machine",
            "equipment maintenance": "machine",
            "farming": "agriculture",
            "agricultural work": "agriculture",
            "agricultural equipment": "agriculture",
            "electrical work": "electrical",
            "basic electrical": "electrical",
            "electrical repair": "electrical",
            "electronics": "electrical",
            "wiring": "electrical",
            "metal work": "welding",
            "fabrication": "welding"
        }

    def _normalize(self, text):
        if not text:
            return ""
        t = text.lower().strip()
        for k, v in self.synonyms.items():
            if k in t:
                return v
        return t

    def _match_list(self, user_list, target_list):
        exact_matched = []
        related_matched = []
        
        for u in user_list:
            u_raw = u.lower().strip()
            u_norm = self._normalize(u)
            
            for t in target_list:
                t_raw = t.lower().strip()
                t_norm = self._normalize(t)
                
                if u_raw in t_raw or t_raw in u_raw:
                    if t not in exact_matched:
                        exact_matched.append(t)
                elif u_norm == t_norm or u_norm in t_norm or t_norm in u_norm:
                    if t not in exact_matched and t not in related_matched:
                        related_matched.append(t)
                        
        return exact_matched, related_matched
        
    def get_recommendations(self, profile: UserProfile):
        scored_careers = []
        user_skills = profile.skills
        user_interests = profile.interests
        user_edu = profile.education
        user_occ = profile.occupation
        user_goal = profile.career_goal

        for career in self.careers:
            # Skill Match (35%)
            required_skills = career.get('skills', [])
            exact_skills, related_skills = self._match_list(user_skills, required_skills)
            total_skill_matches = len(exact_skills) + (len(related_skills) * 0.5) # related skills worth 0.5
            skill_score = min(total_skill_matches / len(required_skills), 1.0) if required_skills else 0

            # Interest Match (30%)
            preferred_interests = career.get('preferred_interests', [])
            # user interests should also match against title, description, skills
            interest_targets = preferred_interests + [career.get('title', ''), career.get('description', '')] + required_skills
            exact_interests, related_interests = self._match_list(user_interests, interest_targets)
            interest_score = min((len(exact_interests) + len(related_interests)) / max(len(preferred_interests), 1), 1.0) if user_interests else 0

            # Occupation Match (15%)
            occupation_score = 0
            if user_occ:
                occ_norm = self._normalize(user_occ)
                desc_norm = self._normalize(career.get('description', ''))
                title_norm = self._normalize(career.get('title', ''))
                
                if occ_norm in desc_norm or occ_norm in title_norm:
                    occupation_score = 1
                else:
                    o_exact, o_related = self._match_list([user_occ], required_skills + preferred_interests)
                    if o_exact or o_related:
                        occupation_score = 1

            # Education Match (10%)
            education_score = 0
            required_edu = career.get('required_education', [])
            if user_edu:
                e_exact, _ = self._match_list([user_edu], required_edu)
                if e_exact:
                    education_score = 1
            if not required_edu or "none" in [e.lower() for e in required_edu]:
                education_score = 1

            # Career Goal Score (10%)
            goal_score = 0
            if user_goal:
                goal_norm = user_goal.lower()
                nsqf = career.get('nsqf_level', 'Level 3')
                
                if "job" in goal_norm or "employment" in goal_norm:
                    # prioritize higher NSQF or job-ready roles
                    if "Level 4" in nsqf or "Level 5" in nsqf:
                        goal_score = 1.0
                    else:
                        goal_score = 0.5
                elif "learn" in goal_norm or "skill" in goal_norm or "training" in goal_norm:
                    # prioritize roles that have explicit training programs (all do)
                    goal_score = 1.0
            
            # Final Score
            final_score = (skill_score * 0.35) + (interest_score * 0.30) + (occupation_score * 0.15) + (education_score * 0.10) + (goal_score * 0.10)
            match_percentage = int(final_score * 100)

            scored_careers.append({
                "career": career,
                "match_percentage": match_percentage,
                "exact_skills": exact_skills,
                "related_skills": related_skills,
                "exact_interests": exact_interests,
                "related_interests": related_interests,
                "education_score": education_score,
                "goal_score": goal_score,
                "occupation_score": occupation_score
            })

        # Sort by match percentage
        scored_careers.sort(key=lambda x: x['match_percentage'], reverse=True)
        top_careers = scored_careers[:3]

        if not top_careers:
            return None

        # Skill gap for the top recommendation
        best_career = top_careers[0]
        required_skills = best_career['career'].get('skills', [])
        all_matched_skills = best_career['exact_skills'] + best_career['related_skills']
        missing_skills = [s for s in required_skills if s not in all_matched_skills]

        recommendations_response = []
        for c in top_careers:
            career_data = c['career']
            c_all_matched = c['exact_skills'] + c['related_skills']
            c_missing = [s for s in career_data.get('skills', []) if s not in c_all_matched]

            why = []
            if c['exact_interests'] or c['related_interests']:
                matching_int = c['exact_interests'][0] if c['exact_interests'] else user_interests[0]
                why.append(f"Matches your interest in {matching_int}")
                
            if c['exact_skills'] or c['related_skills']:
                matching_skill = c['exact_skills'][0] if c['exact_skills'] else c['related_skills'][0]
                why.append(f"Uses your existing skills like {matching_skill}")
                
            if c['education_score'] > 0:
                why.append("Suitable for your education")
                
            if c['goal_score'] > 0:
                if user_goal and ("job" in user_goal.lower() or "employment" in user_goal.lower()):
                    why.append("Aligns with your goal to find a job")
                else:
                    why.append("Aligns with your career goal")
                    
            if not why:
                why.append("Highly matches your overall profile")
                
            match_p = c['match_percentage']
            if match_p >= 80:
                match_level = "Excellent Match"
            elif match_p >= 60:
                match_level = "Good Match"
            elif match_p >= 40:
                match_level = "Moderate Match"
            else:
                match_level = "Low Match"

            recommendations_response.append({
                "career_id": career_data['id'],
                "title": career_data['title'],
                "match_percentage": match_p,
                "match_level": match_level,
                "description": career_data['description'],
                "why_recommended": why,
                "skill_gap_addressed": c_missing,
                "nsqf_level": career_data['nsqf_level'],
                "training_ids": career_data['training_ids']
            })

        return {
            "skill_analysis": {
                "current_skills": user_skills,
                "matched_skills": all_matched_skills,
                "missing_skills": missing_skills
            },
            "recommendations": recommendations_response
        }

    def get_training(self, training_id: str):
        for t in self.trainings:
            if t['id'] == training_id:
                return t
        return None
