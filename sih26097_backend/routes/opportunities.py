from fastapi import APIRouter
from typing import List

router = APIRouter(prefix="/opportunities", tags=["Opportunities"])

def get_demo_opportunities():
    return [
        {
            "id": "opp1",
            "title": "Assistant Tailor",
            "organization": "Local Garment Factory",
            "location": "Nearby (5km)",
            "required_education": "8th Pass",
            "required_skills": ["Sewing", "Measurement"],
            "type": "Job",
            "match_percentage": 85
        },
        {
            "id": "opp2",
            "title": "Apprentice Data Entry",
            "organization": "Tech Solutions Ltd",
            "location": "City Center (12km)",
            "required_education": "10th Pass",
            "required_skills": ["Typing", "Computer Basics"],
            "type": "Apprenticeship",
            "match_percentage": 60
        },
        {
            "id": "opp3",
            "title": "Retail Sales Associate",
            "organization": "Mega Mart",
            "location": "Local Market (2km)",
            "required_education": "10th Pass",
            "required_skills": ["Communication", "Customer Service"],
            "type": "Job",
            "match_percentage": 75
        }
    ]

@router.get("/")
async def list_opportunities():
    return {"opportunities": get_demo_opportunities()}
