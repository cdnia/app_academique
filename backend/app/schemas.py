from datetime import datetime

from pydantic import BaseModel, EmailStr, Field


class StudentCreate(BaseModel):
    first_name: str = Field(..., min_length=1, max_length=100, examples=["Aminata"])
    last_name: str = Field(..., min_length=1, max_length=100, examples=["Ouédraogo"])
    email: EmailStr = Field(..., examples=["aminata.ouedraogo@ujkz.bf"])
    student_id: str = Field(..., min_length=1, max_length=20, examples=["ETU-2024-001"])


class StudentResponse(BaseModel):
    id: int
    first_name: str
    last_name: str
    email: str
    student_id: str
    created_at: datetime

    model_config = {"from_attributes": True}


class GradeResponse(BaseModel):
    id: int
    student_id: int
    subject: str
    score: float
    semester: str
    created_at: datetime

    model_config = {"from_attributes": True}


class PaginatedStudents(BaseModel):
    items: list[StudentResponse]
    total: int
    page: int
    per_page: int


class HealthResponse(BaseModel):
    status: str
    version: str