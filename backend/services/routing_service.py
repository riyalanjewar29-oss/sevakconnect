import json
import math
import urllib.request
from datetime import datetime, timezone
from typing import List, Optional, Tuple
from database import get_db_connection
from models.route import (
    CrowdHotspotDetail,
    RouteOption,
    RoutePoint,
    RoutePreset,
    RouteRecommendRequest,
    RouteRecommendResponse,
)

# Centralized Crowd Penalty Weights
CROWD_PENALTIES = {
    "normal": 0.2,
    "moderate": 1.5,
    "high": 4.5,
    "critical": 9.5,
}

# Distance threshold (km) within which a crowd report affects a road route
CROWD_PROXIMITY_THRESHOLD_KM = 0.25  # 250 meters


def haversine_distance_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculates great-circle distance between two GPS coordinates in kilometers."""
    r = 6371.0
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (
        math.sin(dlat / 2.0) ** 2
        + math.cos(math.radians(lat1))
        * math.cos(math.radians(lat2))
        * math.sin(dlon / 2.0) ** 2
    )
    c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
    return r * c


def min_distance_to_route_km(
    report_lat: float, report_lng: float, route_points: List[RoutePoint]
) -> float:
    """Finds minimum distance from a crowd report coordinate to any road point on the route."""
    if not route_points:
        return float("inf")
    min_dist = float("inf")
    # Sample points for performance if very dense, or evaluate all road points
    step = 1 if len(route_points) < 200 else 2
    for i in range(0, len(route_points), step):
        pt = route_points[i]
        d = haversine_distance_km(report_lat, report_lng, pt.latitude, pt.longitude)
        if d < min_dist:
            min_dist = d
    return min_dist


def fetch_osrm_road_route(
    waypoints: List[Tuple[float, float]],
    profile: str = "driving",
    timeout_secs: int = 8,
) -> Optional[dict]:
    """
    Fetches real road-following geometry from OpenStreetMap via OSRM public API.
    Returns dictionary with road points, distance in km, duration in mins, and road names.
    """
    coord_str = ";".join(f"{lng},{lat}" for lat, lng in waypoints)
    url = f"http://router.project-osrm.org/route/v1/{profile}/{coord_str}?overview=full&geometries=geojson&steps=true"
    req = urllib.request.Request(url, headers={"User-Agent": "SevakConnectRouting/1.0"})

    try:
        with urllib.request.urlopen(req, timeout=timeout_secs) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            if data.get("code") == "Ok" and data.get("routes"):
                route = data["routes"][0]
                coords = route["geometry"]["coordinates"]
                points = [RoutePoint(latitude=c[1], longitude=c[0]) for c in coords]
                dist_km = round(route.get("distance", 0) / 1000.0, 2)
                dur_mins = max(1, int(round(route.get("duration", 0) / 60.0)))

                # Extract real road names from route steps
                road_names = []
                for leg in route.get("legs", []):
                    for step in leg.get("steps", []):
                        name = step.get("name", "").strip()
                        if name and name not in road_names and name.lower() != "unnamed road":
                            road_names.append(name)

                via_road = " / ".join(road_names[:2]) if road_names else "Pandharpur Corridor Road"

                return {
                    "points": points,
                    "distance_km": dist_km,
                    "duration_mins": dur_mins,
                    "via_road": via_road,
                }
    except Exception as e:
        print(f"[RoutingService] OSRM query failed for {waypoints}: {e}")
        return None


class RoutingService:
    @staticmethod
    def get_presets() -> List[RoutePreset]:
        """Provides demo origin and destination checkpoints for Wari corridor."""
        return [
            RoutePreset(
                id="origin_wakhari",
                name="Wakhari Phata Halt",
                latitude=17.7020,
                longitude=75.2900,
                category="origin",
            ),
            RoutePreset(
                id="origin_bhakti_marg",
                name="Bhakti Marg Checkpoint",
                latitude=17.6740,
                longitude=75.3260,
                category="origin",
            ),
            RoutePreset(
                id="dest_mandir",
                name="Vitthal Mandir Complex",
                latitude=17.6775,
                longitude=75.3278,
                category="destination",
            ),
            RoutePreset(
                id="dest_ghat",
                name="Chandrabhaga River Ghat",
                latitude=17.6710,
                longitude=75.3220,
                category="destination",
            ),
        ]

    @staticmethod
    def recommend_route(req: RouteRecommendRequest) -> RouteRecommendResponse:
        """
        Queries OSRM for real road geometries across primary and bypass corridors,
        evaluates live SQLite crowd reports, scores each road route, ranks them,
        and generates an explainable recommendation with crowd hotspots.
        """
        # 1. Fetch active crowd reports from SQLite
        conn = get_db_connection()
        crowd_reports = []
        try:
            cursor = conn.cursor()
            cursor.execute(
                "SELECT id, crowd_level, latitude, longitude, description, estimated_headcount, movement_direction, created_at FROM crowd_reports ORDER BY created_at DESC"
            )
            crowd_reports = cursor.fetchall()
        finally:
            conn.close()

        # Format crowd hotspot list for the UI
        hotspots_list: List[CrowdHotspotDetail] = []
        for r in crowd_reports:
            desc = r["description"] or f"Crowd observation near {r['latitude']:.4f}, {r['longitude']:.4f}"
            loc_name = "Pandharpur Central Junction" if (17.670 <= r["latitude"] <= 17.676 and 75.323 <= r["longitude"] <= 75.328) else "Wari Palkhi Route Corridor"
            hotspots_list.append(
                CrowdHotspotDetail(
                    id=r["id"],
                    crowd_level=r["crowd_level"],
                    location_name=loc_name,
                    description=desc,
                    estimated_headcount=r["estimated_headcount"],
                    latitude=r["latitude"],
                    longitude=r["longitude"],
                    created_at=r["created_at"],
                )
            )

        # 2. Define Corridor Waypoints to retrieve real road routes from OSRM
        # Corridor 1: Direct Primary Road
        w_primary = [(req.start_lat, req.start_lng), (req.dest_lat, req.dest_lng)]

        # Corridor 2: North Canal Bypass Road (via north road corridor)
        mid_north_lat = max(req.start_lat, req.dest_lat) + 0.006
        mid_north_lng = (req.start_lng + req.dest_lng) / 2.0 + 0.003
        w_north = [(req.start_lat, req.start_lng), (17.6820, 75.3240) if abs(req.dest_lat - 17.6775) < 0.05 else (mid_north_lat, mid_north_lng), (req.dest_lat, req.dest_lng)]

        # Corridor 3: South Bypass Road (via southern ring road)
        w_south = [(req.start_lat, req.start_lng), (17.6680, 75.3210) if abs(req.dest_lat - 17.6775) < 0.05 else (min(req.start_lat, req.dest_lat) - 0.006, (req.start_lng + req.dest_lng) / 2.0), (req.dest_lat, req.dest_lng)]

        corridor_definitions = [
            {"id": "route_primary", "name": "Main Palkhi Highway (NH-965)", "desc": "Direct primary highway corridor.", "waypoints": w_primary},
            {"id": "route_north_bypass", "name": "North Canal Bypass Road", "desc": "Perimeter route skirting north of central bottlenecks.", "waypoints": w_north},
            {"id": "route_south_bypass", "name": "South Ring Road", "desc": "Outer southern corridor along the bypass.", "waypoints": w_south},
        ]

        evaluated_routes: List[RouteOption] = []

        # 3. Query OSRM for each corridor to retrieve actual road-snapped geometries
        for c_def in corridor_definitions:
            osrm_data = fetch_osrm_road_route(c_def["waypoints"], profile="driving")
            if not osrm_data:
                # Retry with walking profile if driving route has no path
                osrm_data = fetch_osrm_road_route(c_def["waypoints"], profile="walking")

            if not osrm_data or not osrm_data["points"]:
                continue

            road_points = osrm_data["points"]
            dist_km = osrm_data["distance_km"]
            time_mins = osrm_data["duration_mins"]
            via_road = osrm_data["via_road"]

            # 4. Evaluate crowd reports near this road route
            penalty_sum = 0.0
            critical_hits = 0
            high_hits = 0
            moderate_hits = 0
            affected_count = 0

            for r in crowd_reports:
                r_lat = r["latitude"]
                r_lng = r["longitude"]
                r_level = r["crowd_level"].lower().strip()

                dist_to_route = min_distance_to_route_km(r_lat, r_lng, road_points)
                if dist_to_route <= CROWD_PROXIMITY_THRESHOLD_KM:
                    weight = CROWD_PENALTIES.get(r_level, 0.5)
                    penalty_sum += weight
                    affected_count += 1
                    if r_level == "critical":
                        critical_hits += 1
                    elif r_level == "high":
                        high_hits += 1
                    elif r_level == "moderate":
                        moderate_hits += 1

            if critical_hits > 0:
                risk_tier = "critical"
            elif high_hits > 0:
                risk_tier = "high"
            elif moderate_hits > 0:
                risk_tier = "moderate"
            else:
                risk_tier = "low"

            total_score = round(dist_km * 1.0 + penalty_sum, 2)

            evaluated_routes.append(
                RouteOption(
                    id=c_def["id"],
                    name=c_def["name"],
                    via_road=via_road,
                    description=c_def["desc"],
                    distance_km=dist_km,
                    estimated_time_mins=time_mins,
                    points=road_points,
                    crowd_penalty=round(penalty_sum, 2),
                    crowd_risk=risk_tier,
                    total_score=total_score,
                    is_recommended=False,
                    recommendation_reason="",
                    affected_reports_count=affected_count,
                    avoided_hotspots_count=0,
                )
            )

        if not evaluated_routes:
            raise RuntimeError("OSRM routing service unavailable. Could not fetch road geometry.")

        # 5. Rank routes by total_score ascending (lowest score is best)
        evaluated_routes.sort(key=lambda r: r.total_score)

        # 6. Mark recommended route and calculate avoided hotspots
        recommended = evaluated_routes[0]
        recommended.is_recommended = True

        shortest_dist = min(r.distance_km for r in evaluated_routes)
        max_affected = max((r.affected_reports_count for r in evaluated_routes), default=0)
        avoided = max(0, max_affected - recommended.affected_reports_count)
        recommended.avoided_hotspots_count = avoided

        diff_km = round(recommended.distance_km - shortest_dist, 1)

        if diff_km > 0 and avoided > 0:
            recommended.recommendation_reason = (
                f"This route is {diff_km} km longer than the shortest route, but it avoids "
                f"{avoided} high-density crowd zone{'s' if avoided > 1 else ''}, reducing reported congestion risk."
            )
        elif diff_km > 0:
            recommended.recommendation_reason = (
                f"Recommended alternative: {diff_km} km longer, but offers lower overall crowd congestion penalty."
            )
        else:
            if recommended.affected_reports_count == 0:
                recommended.recommendation_reason = (
                    "Direct route: Shortest travel distance with zero reported high-density crowd hotspots."
                )
            else:
                recommended.recommendation_reason = (
                    f"Direct route: Lowest overall score ({recommended.total_score}) among available corridors."
                )

        # Set reasons for alternatives
        for alt in evaluated_routes[1:]:
            alt.is_recommended = False
            alt.avoided_hotspots_count = max(0, max_affected - alt.affected_reports_count)
            if alt.crowd_risk in ["critical", "high"]:
                alt.recommendation_reason = f"Passes through {alt.affected_reports_count} high-density crowd zone(s)."
            elif alt.crowd_risk == "moderate":
                alt.recommendation_reason = f"Passes near {alt.affected_reports_count} moderate crowd zone(s)."
            else:
                alt.recommendation_reason = f"Alternative road route via {alt.via_road}."

        return RouteRecommendResponse(
            recommended_route=recommended,
            alternatives=evaluated_routes[1:],
            hotspots=hotspots_list,
            total_options=len(evaluated_routes),
            active_crowd_reports_considered=len(crowd_reports),
            timestamp=datetime.now(timezone.utc).isoformat(),
        )
