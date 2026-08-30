from typing import List, Optional
from fastapi import APIRouter, HTTPException, Query, status
from models.task import TaskItem, TaskStatusUpdate, TaskCreate
from repositories.task_repository import TaskRepository

router = APIRouter(prefix="/tasks", tags=["Volunteer Tasks"])


@router.get("", response_model=List[TaskItem], summary="List all volunteer tasks")
def list_tasks(status: Optional[str] = Query(None, description="Filter by task status")):
    """Returns all volunteer operational tasks ordered by priority."""
    try:
        return TaskRepository.get_all_tasks(status=status)
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to fetch tasks: {str(e)}",
        )


@router.get("/{task_id}", response_model=TaskItem, summary="Get task by ID")
def get_task(task_id: str):
    """Fetches single task by ID."""
    task = TaskRepository.get_task_by_id(task_id)
    if not task:
        raise HTTPException(
            status_code=404,
            detail=f"Task '{task_id}' not found",
        )
    return task


@router.patch("/{task_id}/status", response_model=TaskItem, summary="Update task status")
def update_task_status(task_id: str, body: TaskStatusUpdate):
    """Updates status of a task (PENDING, IN PROGRESS, COMPLETED)."""
    valid_statuses = ["PENDING", "IN PROGRESS", "COMPLETED"]
    normalized = body.status.upper()
    if normalized not in valid_statuses:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid status '{body.status}'. Must be one of: {valid_statuses}",
        )
    
    updated = TaskRepository.update_task_status(task_id, normalized)
    if not updated:
        raise HTTPException(
            status_code=404,
            detail=f"Task '{task_id}' not found",
        )
    return updated


@router.post("", response_model=TaskItem, status_code=status.HTTP_201_CREATED, summary="Create a new task")
def create_task(data: TaskCreate):
    """Creates a new volunteer task."""
    try:
        return TaskRepository.create_task(data)
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to create task: {str(e)}",
        )
