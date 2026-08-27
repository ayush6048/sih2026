import os
import json
from typing import List, Optional
from pydantic import BaseModel, Field
from google import genai
from google.genai import types
from dotenv import load_dotenv

load_dotenv()

# We will initialize the client. If GEMINI_API_KEY is in the env, it picks it up automatically.
# We wrap it in a try-except so the import doesn't crash if it's missing initially.
try:
    client = genai.Client()
except Exception as e:
    client = None

class ProfileExtract(BaseModel):
    education: Optional[str] = Field(description="The user's highest education level")
    occupation: Optional[str] = Field(description="The user's current occupation")
    skills: List[str] = Field(description="Specific skills the user has")
    interests: List[str] = Field(description="What the user is interested in learning or doing")
    location: Optional[str] = Field(description="The user's location, district, or area")
    career_goal: Optional[str] = Field(description="The user's main goal (e.g. Find a job, Learn a skill)")

class AIResponse(BaseModel):
    reply: str = Field(description="The next question to ask the user, or a closing message.")
    extracted_data: ProfileExtract = Field(description="Information newly extracted from the user's latest message only")
    next_field: Optional[str] = Field(description="The next field being asked about, or null if complete")
    is_profile_complete: bool = Field(description="True if all fields have been sufficiently gathered")

class AIService:
    def __init__(self):
        self.model_name = "gemini-1.5-flash"

    def process_message(self, user_message: str, current_profile: dict, chat_history: List[dict]) -> dict:
        if not client:
            raise Exception("Gemini client not initialized. Is GEMINI_API_KEY set?")
            
        prompt = f"""
You are a livelihood guidance assistant for users with low digital literacy.
Your job is to understand the user's responses, extract profile information, and ask the next relevant question to build their profile.
Keep questions short. Use simple, respectful, and non-technical language.
Never assume information.
Current profile state:
{json.dumps(current_profile, indent=2)}

User's latest message: "{user_message}"

Review the chat history and the user's latest message.
Extract any NEW information from the user's message into 'extracted_data'. 
Determine what field to ask next (education, occupation, skills, interests, location, career_goal) that is currently null or empty.
Generate a simple 'reply' asking for that information.
If all fields are filled, set is_profile_complete to true and thank them.
"""
        history_text = "\n".join([f"{msg['role']}: {msg['content']}" for msg in chat_history])
        full_prompt = f"Chat History:\n{history_text}\n\n{prompt}"

        response = client.models.generate_content(
            model=self.model_name,
            contents=full_prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                response_schema=AIResponse,
            ),
        )
        
        raw_text = response.text.strip()
        if raw_text.startswith("```json"):
            raw_text = raw_text[7:]
        if raw_text.startswith("```"):
            raw_text = raw_text[3:]
        if raw_text.endswith("```"):
            raw_text = raw_text[:-3]
        
        return json.loads(raw_text.strip())
