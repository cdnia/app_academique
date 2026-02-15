from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models import Student
from app.schemas import PaginatedStudents, StudentCreate, StudentResponse

router = APIRouter(prefix="/api/v1/students", tags=["Students"])


@router.get("/", response_model=PaginatedStudents)
async def list_students(
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
):
    offset = (page - 1) * per_page

    total_result = await db.execute(select(func.count(Student.id)))
    total = total_result.scalar_one()

    result = await db.execute(
        select(Student).order_by(Student.id).offset(offset).limit(per_page)
    )
    students = result.scalars().all()

    return PaginatedStudents(
        items=students, total=total, page=page, per_page=per_page
    )


@router.post("/", response_model=StudentResponse, status_code=201)
async def create_student(
    data: StudentCreate,
    db: AsyncSession = Depends(get_db),
):
    existing = await db.execute(
        select(Student).where(
            (Student.email == data.email) | (Student.student_id == data.student_id)
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=409, detail="Email ou matricule déjà existant")

    student = Student(**data.model_dump())
    db.add(student)
    await db.commit()
    await db.refresh(student)
    return student