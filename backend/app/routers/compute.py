import math

from fastapi import APIRouter, Query

router = APIRouter(prefix="/api/v1/compute", tags=["Compute"])


@router.get("/")
def compute_intensive(
    iterations: int = Query(1_000_000, ge=1, le=10_000_000, description="Nombre d'itérations"),
):
    result = 0.0
    for i in range(1, iterations + 1):
        result += math.sqrt(i) * math.sin(i) / math.log(i + 1)

    return {
        "iterations": iterations,
        "result": round(result, 6),
    }