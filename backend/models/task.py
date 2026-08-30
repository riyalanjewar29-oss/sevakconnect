from typing import Optional
from pydantic import BaseModel, Field


class TaskStatusUpdate(BaseModel):
    status: str = Field(..., description="Task status: PENDING, IN PROGRESS, COMPLETED")


class TaskCreate(BaseModel):
    title: str = Field(..., min_length=2, description="Title of the volunteer task")
    description: str = Field(..., description="Detailed description of task duties")
    priority: str = Field("MEDIUM", description="Priority level: LOW, MEDIUM, HIGH, CRITICAL")
    status: str = Field("PENDING", description="Status: PENDING, IN PROGRESS, COMPLETED")
    assigned_to: str = Field("volunteer_demo", description="Assigned volunteer or group")
    location_name: str = Field("Wari Route", description="Location name or landmark")
    latitude: Optional[float] = None
    longitude: Optional[float] = None


class TaskItem(BaseModel):
    id: str
    title: str
    description: str
    priority: str
    status: str
    assigned_to: str
    location_name: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    created_at: str
    updated_at: str
