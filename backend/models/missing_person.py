from typing import Optional
from pydantic import BaseModel, Field


class MissingPersonCreate(BaseModel):
    name: Optional[str] = Field(None, description="Name of missing person if known")
    age: Optional[int] = Field(None, description="Age in years")
    gender: Optional[str] = Field(None, description="Gender: Male, Female, Other")
    description: str = Field(..., min_length=3, description="Physical appearance, clothes, and circumstances")
    latitude: float
    longitude: float
    is_minor: bool = Field(False, description="Whether the missing person is a minor child")
    reported_by: Optional[str] = Field("volunteer_demo", description="Volunteer identifier")
    additional_info: Optional[str] = Field(None, description="Contact details, medical conditions, etc.")
    photo_url: Optional[str] = Field(None, description="Reference URL or path for missing person photo")


class MissingPersonItem(BaseModel):
    id: str
    name: Optional[str] = None
    age: Optional[int] = None
    gender: Optional[str] = None
    description: str
    latitude: float
    longitude: float
    is_minor: bool
    reported_by: str
    additional_info: Optional[str] = None
    status: str
    photo_url: Optional[str] = None
    created_at: str
    updated_at: str


class MissingPersonCreateResponse(BaseModel):
    case_id: str
    status: str
    created_at: str
    alert_created: bool = False
