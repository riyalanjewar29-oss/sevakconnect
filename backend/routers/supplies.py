from typing import List, Optional
from fastapi import APIRouter, HTTPException, Query
from models.supply import SupplyItem, SupplyUpdateRequest, SupplyUpdateResponse
from repositories.supply_repository import SupplyRepository

router = APIRouter(prefix="/supplies", tags=["Supplies"])


@router.get("", response_model=List[SupplyItem])
def get_supplies(location: Optional[str] = Query(default=None, description="Optional halt location filter")):
    """Retrieves operational camp supplies inventory from SQLite."""
    try:
        return SupplyRepository.get_all(location=location)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch supplies: {str(e)}")


@router.post("/update", response_model=SupplyUpdateResponse)
def update_supply(req: SupplyUpdateRequest):
    """Updates or creates a camp supply inventory record in SQLite."""
    try:
        updated_item = SupplyRepository.update_or_create(req)
        return SupplyUpdateResponse(
            success=True,
            message="Supply inventory updated successfully.",
            supply=updated_item,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to update supply: {str(e)}")
