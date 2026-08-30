from typing import Optional
from pydantic import BaseModel, Field


class FacilityItem(BaseModel):
    id: str
    name: str
    type: str  # medical, water, toilets, food, security
    location_name: str
    latitude: float
    longitude: float
    status: str  # OPEN, AVAILABLE, LIMITED, CLOSED
    description: Optional[str] = None
    contact_info: Optional[str] = None
    updated_at: str
