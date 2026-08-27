from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import json
import os

router = APIRouter(prefix="/courses", tags=["Courses"])

# Mock database
# user_id -> list of enrolled courses
enrolled_courses_db = {}

def get_all_courses():
    try:
        with open(os.path.join(os.path.dirname(__file__), "..", "data", "training.json"), "r") as f:
            return json.load(f)
    except Exception:
        return [
            {
                "id": "c1",
                "title": "Basic Tailoring & Sewing",
                "provider": "NSDC",
                "nsqf_level": "Level 3",
                "duration": "3 months",
                "skills_developed": ["Sewing", "Measurement", "Fabric cutting"],
                "description": "Learn basic tailoring and sewing techniques.",
                "eligibility": "8th Pass",
                "category": "Apparel"
            },
            {
                "id": "c2",
                "title": "Data Entry Operator",
                "provider": "Skill India",
                "nsqf_level": "Level 4",
                "duration": "2 months",
                "skills_developed": ["Typing", "Data Entry", "Basic Computer"],
                "description": "Become a certified data entry operator.",
                "eligibility": "10th Pass",
                "category": "IT"
            }
        ]

class EnrollRequest(BaseModel):
    user_id: str
    course_id: str

@router.get("/")
async def explore_courses():
    return {"courses": get_all_courses()}

@router.post("/register")
async def register_course(request: EnrollRequest):
    all_courses = get_all_courses()
    course = next((c for c in all_courses if c["id"] == request.course_id), None)
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")
    
    if request.user_id not in enrolled_courses_db:
        enrolled_courses_db[request.user_id] = []
        
    if any(c["id"] == request.course_id for c in enrolled_courses_db[request.user_id]):
        return {"message": "Already registered"}
        
    enrolled_course = dict(course)
    enrolled_course["progress"] = 0
    enrolled_course["status"] = "Not Started"
    
    enrolled_courses_db[request.user_id].append(enrolled_course)
    
    return {"message": "Successfully registered", "course": enrolled_course}

@router.get("/enrolled/{user_id}")
async def get_enrolled_courses(user_id: str):
    courses = enrolled_courses_db.get(user_id, [])
    return {"enrolled_courses": courses}
