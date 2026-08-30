from typing import List
from fastapi import APIRouter, HTTPException, status
from models.route import RoutePreset, RouteRecommendRequest, RouteRecommendResponse
from services.routing_service import RoutingService

router = APIRouter(prefix="/routes", tags=["routes"])


@router.post(
    "/recommend",
    response_model=RouteRecommendResponse,
    status_code=status.HTTP_200_OK,
    summary="Compute crowd-aware route recommendations",
)
def recommend_route(request: RouteRecommendRequest):
    """
    Evaluates available Wari pilgrimage corridors against live crowd reports stored in SQLite.
    Returns the recommended lower-congestion route along with ranked alternative options and explanations.
    """
    try:
        return RoutingService.recommend_route(request)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to calculate route recommendations: {str(e)}",
        )


@router.get(
    "/presets",
    response_model=List[RoutePreset],
    summary="Get standard Wari corridor origin and destination checkpoints",
)
def get_route_presets():
    """Returns demo origin and destination checkpoints for quick route evaluation."""
    return RoutingService.get_presets()
