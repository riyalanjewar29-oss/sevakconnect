from typing import List, Optional
from fastapi import APIRouter, HTTPException, Query
from models.alert import AlertItem, AlertReadResponse
from repositories.alert_repository import AlertRepository

router = APIRouter(prefix="/alerts", tags=["Operational Alerts"])


@router.get("", response_model=List[AlertItem])
def get_alerts(
    unread_only: bool = Query(False, description="Filter for unread alerts only"),
    severity: Optional[str] = Query(None, description="Filter by severity (CRITICAL, HIGH, WARNING, INFO)"),
):
    """Returns operational alerts ordered by severity priority and recency."""
    try:
        return AlertRepository.get_all_alerts(unread_only=unread_only, severity=severity)
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to fetch operational alerts: {str(e)}",
        )


@router.patch("/{alert_id}/read", response_model=AlertReadResponse)
def mark_alert_as_read(alert_id: str):
    """Marks an operational alert as read."""
    updated = AlertRepository.mark_as_read(alert_id)
    if not updated:
        raise HTTPException(
            status_code=404,
            detail=f"Alert '{alert_id}' not found",
        )
    return AlertReadResponse(
        alert_id=updated.id,
        is_read=updated.is_read,
        status="success",
    )
