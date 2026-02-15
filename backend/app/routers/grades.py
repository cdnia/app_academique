from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models import Grade
from app.schemas import GradeResponse

router = APIRouter(prefix="/api/v1/grades", tags=["Grades"])


@router.get("/", response_model=list[GradeResponse])
async def list_grades(
    student_id: int | None = Query(None, description="Filtrer par étudiant"),
    subject: str | None = Query(None, description="Filtrer par matière"),
    db: AsyncSession = Depends(get_db),
):
    query = select(Grade).order_by(Grade.id)

    if student_id is not None:
        query = query.where(Grade.student_id == student_id)
    if subject is not None:
        query = query.where(Grade.subject == subject)

    result = await db.execute(query)
    return result.scalars().all()