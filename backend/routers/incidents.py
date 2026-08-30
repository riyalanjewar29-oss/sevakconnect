from typing import List
from fastapi import APIRouter, HTTPException, status
from models.incident import IncidentCreateRequest, IncidentDetail, IncidentResponse
from repositories.incident_repository import IncidentRepository

router = APIRouter(prefix="/incidents", tags=["incidents"])


@router.post(
    "",
    response_model=IncidentResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create a new incident report",
)
def create_incident(incident: IncidentCreateRequest):
    """
    Creates an incident report with GPS coordinates and persists it to SQLite.
    Returns the created incident_id, status, and created_at timestamp.
    """
    try:
        return IncidentRepository.create(incident)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to persist incident: {str(e)}",
        )


@router.get(
    "",
    response_model=List[IncidentDetail],
    summary="List all incident reports",
)
def list_incidents():
    """Returns all incidents ordered by creation time descending."""
    return IncidentRepository.list_all()


@router.get(
    "/{incident_id}",
    response_model=IncidentDetail,
    summary="Get incident report by ID",
)
def get_incident(incident_id: str):
    """Fetches an incident report by its unique ID."""
    incident = IncidentRepository.get_by_id(incident_id)
    if not incident:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Incident '{incident_id}' not found",
        )
    return incident
