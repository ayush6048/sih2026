from typing import List, Optional
from pydantic import BaseModel

class ProfileRequest(BaseModel):
    education: str
    occupation: str
    skills: List[str]
    interest: str
    location: str
    goal: str
