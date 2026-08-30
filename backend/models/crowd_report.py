from typing import Optional
from pydantic import BaseModel, Field


class CrowdReportCreateRequest(BaseModel):
    crowd_level: str = Field(..., description="Crowd level: normal, moderate, high, critical")
    estimated_headcount: Optional[int] = Field(default=None, description="Estimated approximate headcount")
    movement_direction: Optional[str] = Field(default=None, description="Movement direction or flow status")
    description: Optional[str] = Field(default="", description="Optional crowd condition description or landmarks")
    latitude: float = Field(..., description="GPS latitude coordinate")
    longitude: float = Field(..., description="GPS longitude coordinate")
    reported_by: Optional[str] = Field(default="volunteer_demo", description="Identifier of reporter")


class CrowdReportResponse(BaseModel):
    report_id: str
    status: str
    created_at: str


class CrowdReportDetail(BaseModel):
    id: str
    crowd_level: str
    estimated_headcount: Optional[int]
    movement_direction: Optional[str]
    description: Optional[str]
    latitude: float
    longitude: float
    reported_by: str
    created_at: str


class CrowdSummaryResponse(BaseModel):
    total: int
    normal: int
    moderate: int
    high: int
    critical: int
