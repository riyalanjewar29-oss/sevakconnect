from typing import List, Optional
from pydantic import BaseModel, Field


class RoutePoint(BaseModel):
    latitude: float
    longitude: float


class CrowdHotspotDetail(BaseModel):
    id: str
    crowd_level: str
    location_name: str
    description: str
    estimated_headcount: Optional[int] = None
    latitude: float
    longitude: float
    created_at: str


class RouteOption(BaseModel):
    id: str
    name: str
    via_road: str
    description: str
    distance_km: float
    estimated_time_mins: int
    points: List[RoutePoint]
    crowd_penalty: float
    crowd_risk: str  # low, moderate, high, critical
    total_score: float
    is_recommended: bool
    recommendation_reason: str
    affected_reports_count: int
    avoided_hotspots_count: int = 0


class RouteRecommendRequest(BaseModel):
    start_lat: float = Field(..., description="Start latitude coordinate")
    start_lng: float = Field(..., description="Start longitude coordinate")
    dest_lat: float = Field(..., description="Destination latitude coordinate")
    dest_lng: float = Field(..., description="Destination longitude coordinate")
    origin_name: Optional[str] = Field(default="Current Location", description="Label for origin")
    destination_name: Optional[str] = Field(default="Vitthal Mandir Complex", description="Label for destination")


class RoutePreset(BaseModel):
    id: str
    name: str
    latitude: float
    longitude: float
    category: str  # origin, destination


class RouteRecommendResponse(BaseModel):
    recommended_route: RouteOption
    alternatives: List[RouteOption]
    hotspots: List[CrowdHotspotDetail]
    total_options: int
    active_crowd_reports_considered: int
    timestamp: str
