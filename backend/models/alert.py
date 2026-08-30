from typing import Optional
from pydantic import BaseModel, Field


class AlertItem(BaseModel):
    id: str = Field(..., description="Unique Alert Identifier e.g. ALT-CRW-001")
    title: str = Field(..., description="Headline of the operational alert")
    description: str = Field(..., description="Details and actionable guidance")
    type: str = Field(..., description="Alert category: crowd, river_safety, emergency, route, supply, general")
    severity: str = Field(..., description="Severity level: CRITICAL, HIGH, WARNING, INFO")
    location: Optional[str] = Field("", description="Affected halt, zone, or corridor")
    created_at: str = Field(..., description="ISO 8601 UTC timestamp")
    is_read: bool = Field(False, description="Read state for volunteer")


class AlertReadResponse(BaseModel):
    alert_id: str
    is_read: bool
    status: str
