from fastapi import APIRouter, HTTPException
from services.recommendation_service import RecommendationService, UserProfile

router = APIRouter()
rec_service = RecommendationService()

@router.post("/recommendations")
async def get_recommendations(profile: UserProfile):
    try:
        result = rec_service.get_recommendations(profile)
        if not result:
            return {"skill_analysis": {"current_skills": profile.skills, "matched_skills": [], "missing_skills": []}, "recommendations": []}
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/training/{training_id}")
async def get_training_details(training_id: str):
    training = rec_service.get_training(training_id)
    if not training:
        raise HTTPException(status_code=404, detail="Training not found")
    return training
