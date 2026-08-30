from typing import Optional
from pydantic import BaseModel, Field


class RiverZoneItem(BaseModel):
    id: str = Field(..., description="Unique Zone Identifier e.g. RIV-ZN-001")
    name: str = Field(..., description="Zone name in English")
    marathi_name: Optional[str] = Field("", description="Zone name in Marathi")
    latitude: float
    longitude: float
    current_headcount: int = Field(0, description="Estimated current warkaris in zone")
    safe_capacity: int = Field(5000, description="Maximum recommended safe capacity")
    water_speed: float = Field(1.5, description="Current river flow speed in m/s")
    restricted_entry: bool = Field(False, description="Whether bathing/entry is restricted")
    density: str = Field("normal", description="Crowd density level (normal, high, critical)")
    safety_warning: Optional[str] = Field("", description="Specific safety advisory")
    updated_at: str = Field(..., description="ISO 8601 UTC timestamp")

    @property
    def capacity_percentage(self) -> float:
        if self.safe_capacity <= 0:
            return 0.0
        return round((self.current_headcount / self.safe_capacity) * 100, 1)

    @property
    def calculated_status(self) -> str:
        if self.restricted_entry:
            return "CRITICAL"
        ratio = self.current_headcount / self.safe_capacity if self.safe_capacity > 0 else 0
        if ratio >= 1.0:
            return "CRITICAL"
        elif ratio >= 0.8:
            return "HIGH"
        elif ratio >= 0.6:
            return "MODERATE"
        return "SAFE"
