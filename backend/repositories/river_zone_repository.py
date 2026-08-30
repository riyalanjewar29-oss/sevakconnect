from typing import List, Optional
from database import get_db_connection
from models.river_zone import RiverZoneItem


class RiverZoneRepository:
    """Repository handling SQLite database interactions for Chandrabhaga Safety Zones."""

    @staticmethod
    def get_all_zones() -> List[RiverZoneItem]:
        """Retrieves all Chandrabhaga river safety zones."""
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.execute(
                """
                SELECT id, name, marathi_name, latitude, longitude, current_headcount,
                       safe_capacity, water_speed, restricted_entry, density, safety_warning, updated_at
                FROM river_zones
                ORDER BY id ASC
                """
            )
            rows = cursor.fetchall()
            return [
                RiverZoneItem(
                    id=row["id"],
                    name=row["name"],
                    marathi_name=row["marathi_name"] or "",
                    latitude=float(row["latitude"]),
                    longitude=float(row["longitude"]),
                    current_headcount=int(row["current_headcount"]),
                    safe_capacity=int(row["safe_capacity"]),
                    water_speed=float(row["water_speed"]),
                    restricted_entry=bool(row["restricted_entry"]),
                    density=row["density"] or "normal",
                    safety_warning=row["safety_warning"] or "",
                    updated_at=row["updated_at"],
                )
                for row in rows
            ]
        finally:
            conn.close()

    @staticmethod
    def get_zone_by_id(zone_id: str) -> Optional[RiverZoneItem]:
        """Retrieves a single zone by ID."""
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.execute(
                """
                SELECT id, name, marathi_name, latitude, longitude, current_headcount,
                       safe_capacity, water_speed, restricted_entry, density, safety_warning, updated_at
                FROM river_zones
                WHERE id = ?
                """,
                (zone_id,),
            )
            row = cursor.fetchone()
            if not row:
                return None
            return RiverZoneItem(
                id=row["id"],
                name=row["name"],
                marathi_name=row["marathi_name"] or "",
                latitude=float(row["latitude"]),
                longitude=float(row["longitude"]),
                current_headcount=int(row["current_headcount"]),
                safe_capacity=int(row["safe_capacity"]),
                water_speed=float(row["water_speed"]),
                restricted_entry=bool(row["restricted_entry"]),
                density=row["density"] or "normal",
                safety_warning=row["safety_warning"] or "",
                updated_at=row["updated_at"],
            )
        finally:
            conn.close()
