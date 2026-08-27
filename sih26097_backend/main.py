from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes.conversation import router as conversation_router
from routes.recommendations import router as recommendations_router
from routes.auth import router as auth_router
from routes.courses import router as courses_router
from routes.opportunities import router as opportunities_router
from models.profile import ProfileRequest

app = FastAPI(title="SIH26097 Backend API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(conversation_router)
app.include_router(recommendations_router)
app.include_router(auth_router)
app.include_router(courses_router)
app.include_router(opportunities_router)

@app.get("/health")
async def health_check():
    return {
        "status": "ok",
        "project": "SIH26097"
    }

@app.post("/profile")
async def submit_profile(profile: ProfileRequest):
    return profile.model_dump()

