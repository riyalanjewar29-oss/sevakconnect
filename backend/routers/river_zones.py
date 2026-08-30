from typing import List
from fastapi import APIRouter, HTTPException
from models.river_zone import RiverZoneItem
from repositories.river_zone_repository import RiverZoneRepository

router = APIRouter(prefix="/river/zones", tags=["River Safety Zones"])


@router.get("", response_model=List[RiverZoneItem])
def get_river_zones():
    """Returns all Chandrabhaga River Safety Zones with crowd capacity and flow velocity."""
    try:
        return RiverZoneRepository.get_all_zones()
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to fetch river safety zones: {str(e)}",
        )


@router.get("/{zone_id}", response_model=RiverZoneItem)
def get_river_zone_by_id(zone_id: str):
    """Returns a specific river zone by ID."""
    zone = RiverZoneRepository.get_zone_by_id(zone_id)
    if not zone:
        raise HTTPException(
            status_code=404,
            detail=f"River safety zone '{zone_id}' not found",
        )
    return zone
