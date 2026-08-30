from typing import List, Optional
from fastapi import APIRouter, HTTPException, Query
from models.missing_person import MissingPersonCreate, MissingPersonItem, MissingPersonCreateResponse
from repositories.missing_person_repository import MissingPersonRepository

router = APIRouter(prefix="/missing-persons", tags=["Missing Persons"])


@router.post("", response_model=MissingPersonCreateResponse)
def report_missing_person(data: MissingPersonCreate):
    """Submits a new missing person report and triggers alerts for minors."""
    try:
        return MissingPersonRepository.create_case(data)
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to submit missing person report: {str(e)}",
        )


@router.get("", response_model=List[MissingPersonItem])
def get_missing_persons(
    status: Optional[str] = Query(None, description="Filter by status (OPEN, SEARCHING, FOUND, CLOSED)"),
):
    """Returns list of active missing person cases."""
    try:
        return MissingPersonRepository.get_all_cases(status=status)
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to fetch missing persons: {str(e)}",
        )


@router.get("/{case_id}", response_model=MissingPersonItem)
def get_missing_person_case(case_id: str):
    """Returns details for a specific missing person case."""
    case = MissingPersonRepository.get_case_by_id(case_id)
    if not case:
        raise HTTPException(
            status_code=404,
            detail=f"Missing person case '{case_id}' not found",
        )
    return case
