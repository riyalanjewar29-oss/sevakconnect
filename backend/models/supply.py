from typing import Optional
from pydantic import BaseModel, Field


class SupplyItem(BaseModel):
    id: str
    resource: str  # water, food, medical
    resource_name: str
    quantity: int
    required_quantity: int
    unit: str
    location: str
    status: str  # AVAILABLE, LOW, CRITICAL
    updated_at: str


class SupplyUpdateRequest(BaseModel):
    resource: str = Field(..., description="Resource identifier: water, food, or medical")
    quantity: int = Field(..., ge=0, description="Current recorded inventory quantity")
    required_quantity: Optional[int] = Field(default=None, ge=1, description="Required target inventory quantity")
    location: str = Field(default="Wakhari Phata", description="Halt location name")
    unit: Optional[str] = Field(default=None, description="Units e.g. Liters, Packets, Kits")


class SupplyUpdateResponse(BaseModel):
    success: bool
    message: str
    supply: SupplyItem
