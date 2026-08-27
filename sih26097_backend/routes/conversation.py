from fastapi import APIRouter
from pydantic import BaseModel
from typing import List, Optional, Dict
from services.ai_service import AIService

router = APIRouter()
ai_service = AIService()

# In-memory storage for prototype
conversations: Dict[str, dict] = {}

class ConversationRequest(BaseModel):
    message: str
    conversation_id: str

@router.post("/conversation")
async def process_conversation(req: ConversationRequest):
    cid = req.conversation_id
    if cid not in conversations:
        conversations[cid] = {
            "profile": {
                "education": None,
                "occupation": None,
                "skills": [],
                "interests": [],
                "location": None,
                "career_goal": None
            },
            "messages": []
        }
    
    conv = conversations[cid]
    
    try:
        ai_result = ai_service.process_message(req.message, conv["profile"], conv["messages"])
        
        extracted = ai_result.get("extracted_data", {})
        for k, v in extracted.items():
            if v:
                if isinstance(v, list):
                    conv["profile"][k].extend(v)
                    conv["profile"][k] = list(set(conv["profile"][k]))
                else:
                    conv["profile"][k] = v
                    
        reply = ai_result.get("reply", "I see. Could you tell me more?")
        
        conv["messages"].append({"role": "User", "content": req.message})
        conv["messages"].append({"role": "AI", "content": reply})
        
        return {
            "reply": reply,
            "extracted_data": extracted,
            "profile": conv["profile"],
            "next_field": ai_result.get("next_field"),
            "is_profile_complete": ai_result.get("is_profile_complete", False)
        }
    except Exception as e:
        print(f"Error processing AI message: {e}")
        return {
            "reply": "Sorry, I couldn't process that. Please try again.",
            "extracted_data": {},
            "profile": conv["profile"],
            "next_field": None,
            "is_profile_complete": False
        }
