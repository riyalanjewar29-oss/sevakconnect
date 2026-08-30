from typing import Optional
from pydantic import BaseModel, Field


class IncidentCreateRequest(BaseModel):
    type: str = Field(..., description="Type of incident: medical, crowd, missing, safety, other")
    severity: str = Field(..., description="Severity level: low, medium, high, critical")
    description: Optional[str] = Field(default="", description="Incident details or notes")
    latitude: float = Field(..., description="GPS latitude coordinate")
    longitude: float = Field(..., description="GPS longitude coordinate")
    reported_by: Optional[str] = Field(default="volunteer_demo", description="Identifier of reporter")


class IncidentResponse(BaseModel):
    incident_id: str
    status: str
    created_at: str


class IncidentDetail(BaseModel):
    id: str
    type: str
    severity: str
    description: Optional[str]
    latitude: float
    longitude: float
    reported_by: str
    status: str
    created_at: str
