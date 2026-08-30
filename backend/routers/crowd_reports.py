from typing import List
from fastapi import APIRouter, HTTPException, status
from models.crowd_report import (
    CrowdReportCreateRequest,
    CrowdReportDetail,
    CrowdReportResponse,
    CrowdSummaryResponse,
)
from repositories.crowd_report_repository import CrowdReportRepository

router = APIRouter(prefix="/crowd-reports", tags=["crowd-reports"])


@router.post(
    "",
    response_model=CrowdReportResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create a new crowd report",
)
def create_crowd_report(report: CrowdReportCreateRequest):
    """
    Creates a crowd condition report with GPS coordinates and stores it in SQLite.
    Returns the assigned report_id, status, and created_at timestamp.
    """
    try:
        return CrowdReportRepository.create(report)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to persist crowd report: {str(e)}",
        )


@router.get(
    "",
    response_model=List[CrowdReportDetail],
    summary="List all crowd reports",
)
def list_crowd_reports():
    """Returns all crowd reports ordered by creation time descending."""
    return CrowdReportRepository.list_all()


@router.get(
    "/summary",
    response_model=CrowdSummaryResponse,
    summary="Get crowd conditions summary count",
)
def get_crowd_summary():
    """Returns aggregated count of normal, moderate, high, and critical crowd reports."""
    return CrowdReportRepository.get_summary()


@router.get(
    "/{report_id}",
    response_model=CrowdReportDetail,
    summary="Get crowd report by ID",
)
def get_crowd_report(report_id: str):
    """Fetches a specific crowd report by its unique ID."""
    report = CrowdReportRepository.get_by_id(report_id)
    if not report:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Crowd report '{report_id}' not found",
        )
    return report
