from typing import List, Optional
from fastapi import APIRouter, HTTPException, Query
from models.facility import FacilityItem
from repositories.facility_repository import FacilityRepository

router = APIRouter(prefix="/facilities", tags=["Facilities"])


@router.get("", response_model=List[FacilityItem])
def get_facilities(type: Optional[str] = Query(default=None, description="Optional facility category filter: medical, water, toilets, food, security")):
    """Retrieves operational facilities directory from SQLite."""
    try:
        return FacilityRepository.get_all(facility_type=type)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch facilities: {str(e)}")
