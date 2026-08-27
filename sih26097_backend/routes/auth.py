from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

router = APIRouter(prefix="/auth", tags=["Authentication"])

class SendOTPRequest(BaseModel):
    mobile_number: str

class VerifyOTPRequest(BaseModel):
    mobile_number: str
    otp: str

# In-memory store for OTPs (Mock)
otp_store = {}

@router.post("/send-otp")
async def send_otp(request: SendOTPRequest):
    if len(request.mobile_number) != 10 or not request.mobile_number.isdigit():
        raise HTTPException(status_code=400, detail="Invalid mobile number")
    
    # Generate a fixed OTP for demo purposes. 
    otp = "123456" 
    otp_store[request.mobile_number] = otp
    
    return {"message": "OTP sent successfully", "otp": otp} # Returning OTP for easy demo

@router.post("/verify-otp")
async def verify_otp(request: VerifyOTPRequest):
    stored_otp = otp_store.get(request.mobile_number)
    if not stored_otp or stored_otp != request.otp:
        raise HTTPException(status_code=401, detail="Invalid or expired OTP")
    
    # Clear OTP
    del otp_store[request.mobile_number]
    
    return {
        "message": "Login successful", 
        "token": f"mock_token_{request.mobile_number}",
        "user": {
            "mobile_number": request.mobile_number,
            "id": f"usr_{request.mobile_number}"
        }
    }
