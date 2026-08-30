from typing import List
from fastapi import APIRouter, HTTPException
from models.halt import HaltItem, HaltReadinessUpdate
from repositories.halt_repository import HaltRepository

router = APIRouter(prefix="/halts", tags=["Halt & Camp Readiness"])


@router.get("", response_model=List[HaltItem])
def get_halts():
    """Returns all Halt Camps along with algorithmic readiness score and deficits."""
    try:
        return HaltRepository.get_all_halts()
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to fetch halts: {str(e)}",
        )


@router.get("/{halt_id}", response_model=HaltItem)
def get_halt(halt_id: str):
    """Returns detailed metrics for a specific halt."""
    halt = HaltRepository.get_halt_by_id(halt_id)
    if not halt:
        raise HTTPException(
            status_code=404,
            detail=f"Halt '{halt_id}' not found",
        )
    return halt


@router.get("/{halt_id}/readiness", response_model=HaltItem)
def get_halt_readiness(halt_id: str):
    """Returns detailed readiness metrics for a specific halt."""
    halt = HaltRepository.get_halt_by_id(halt_id)
    if not halt:
        raise HTTPException(
            status_code=404,
            detail=f"Halt '{halt_id}' not found",
        )
    return halt


@router.patch("/{halt_id}/readiness", response_model=HaltItem)
def update_halt_readiness(halt_id: str, data: HaltReadinessUpdate):
    """Updates resource quantities for a halt and recomputes readiness score in real-time."""
    updated = HaltRepository.update_readiness(halt_id, data)
    if not updated:
        raise HTTPException(
            status_code=404,
            detail=f"Halt '{halt_id}' not found",
        )
    return updated
