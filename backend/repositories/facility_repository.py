from typing import List, Optional
from database import get_db_connection
from models.facility import FacilityItem


class FacilityRepository:
    @staticmethod
    def get_all(facility_type: Optional[str] = None) -> List[FacilityItem]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            if facility_type and facility_type.lower() != "all":
                cursor.execute(
                    "SELECT * FROM facilities WHERE LOWER(type) = LOWER(?) ORDER BY name ASC",
                    (facility_type,),
                )
            else:
                cursor.execute("SELECT * FROM facilities ORDER BY type ASC, name ASC")
            rows = cursor.fetchall()
            return [
                FacilityItem(
                    id=row["id"],
                    name=row["name"],
                    type=row["type"],
                    location_name=row["location_name"],
                    latitude=row["latitude"],
                    longitude=row["longitude"],
                    status=row["status"],
                    description=row["description"],
                    contact_info=row["contact_info"],
                    updated_at=row["updated_at"],
                )
                for row in rows
            ]
        finally:
            conn.close()
