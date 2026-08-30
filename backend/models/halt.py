from typing import List, Optional
from pydantic import BaseModel, Field


class HaltReadinessUpdate(BaseModel):
    water_capacity_liters: Optional[int] = Field(None, description="Current water available in Liters")
    food_packets_available: Optional[int] = Field(None, description="Available ration / meal packets")
    sanitation_facilities: Optional[int] = Field(None, description="Operational toilets / bio-toilets")
    medical_teams: Optional[int] = Field(None, description="Active doctor & triage teams")
    crowd_marshals: Optional[int] = Field(None, description="Deployed sevaks & marshals")


class HaltItem(BaseModel):
    id: str
    name: str
    dindi_name: str
    latitude: float
    longitude: float
    expected_varkaris: int
    expected_arrival: str
    water_capacity_liters: int
    food_packets_available: int
    sanitation_facilities: int
    medical_teams: int
    crowd_marshals: int
    readiness_score: float
    readiness_level: str
    flagged_deficits: List[str] = []
    updated_at: str
