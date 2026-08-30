import math
from datetime import datetime, timezone
from typing import List, Optional
from database import get_db_connection
from models.halt import HaltItem, HaltReadinessUpdate


def compute_halt_readiness(
    expected_varkaris: int,
    water_liters: int,
    food_packets: int,
    toilets: int,
    medical_teams: int,
    marshals: int,
) -> tuple[float, str, List[str]]:
    """Calculates algorithmic readiness score, level, and deficits."""
    if expected_varkaris <= 0:
        return 100.0, "READY", []

    water_ratio = min(1.0, max(0.0, water_liters / (expected_varkaris * 3.0)))
    food_ratio = min(1.0, max(0.0, food_packets / float(expected_varkaris)))
    sanitation_ratio = min(1.0, max(0.0, toilets / (expected_varkaris / 100.0)))
    medical_ratio = min(1.0, max(0.0, medical_teams / max(1.0, expected_varkaris / 2000.0)))
    marshal_ratio = min(1.0, max(0.0, marshals / (expected_varkaris / 250.0)))

    total = (
        (water_ratio * 30.0)
        + (sanitation_ratio * 25.0)
        + (food_ratio * 20.0)
        + (medical_ratio * 15.0)
        + (marshal_ratio * 10.0)
    )
    score = round(total, 1)

    if score >= 80.0:
        level = "READY"
    elif score >= 50.0:
        level = "MODERATE"
    else:
        level = "NOT READY"

    deficits = []
    if water_liters < expected_varkaris * 3:
        deficits.append(f"Water shortage: {(expected_varkaris * 3) - water_liters} L deficit")
    if food_packets < expected_varkaris:
        deficits.append(f"Meals shortage: {expected_varkaris - food_packets} packets deficit")
    if toilets < math.ceil(expected_varkaris / 100):
        deficits.append(f"Sanitation deficit: {math.ceil(expected_varkaris / 100) - toilets} units missing")
    if medical_teams < math.ceil(expected_varkaris / 2000):
        deficits.append("Inadequate medical response teams")
    if marshals < math.ceil(expected_varkaris / 250):
        deficits.append(f"Volunteer deficit: {math.ceil(expected_varkaris / 250) - marshals} marshals needed")

    return score, level, deficits


class HaltRepository:
    """Repository handling SQLite database interactions for Halt & Camp Readiness."""

    @staticmethod
    def get_all_halts() -> List[HaltItem]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM halts ORDER BY id ASC")
            rows = cursor.fetchall()
            results = []
            for row in rows:
                score, level, deficits = compute_halt_readiness(
                    expected_varkaris=int(row["expected_varkaris"]),
                    water_liters=int(row["water_capacity_liters"]),
                    food_packets=int(row["food_packets_available"]),
                    toilets=int(row["sanitation_facilities"]),
                    medical_teams=int(row["medical_teams"]),
                    marshals=int(row["crowd_marshals"]),
                )
                results.append(
                    HaltItem(
                        id=row["id"],
                        name=row["name"],
                        dindi_name=row["dindi_name"],
                        latitude=float(row["latitude"]),
                        longitude=float(row["longitude"]),
                        expected_varkaris=int(row["expected_varkaris"]),
                        expected_arrival=row["expected_arrival"],
                        water_capacity_liters=int(row["water_capacity_liters"]),
                        food_packets_available=int(row["food_packets_available"]),
                        sanitation_facilities=int(row["sanitation_facilities"]),
                        medical_teams=int(row["medical_teams"]),
                        crowd_marshals=int(row["crowd_marshals"]),
                        readiness_score=score,
                        readiness_level=level,
                        flagged_deficits=deficits,
                        updated_at=row["updated_at"],
                    )
                )
            return results
        finally:
            conn.close()

    @staticmethod
    def get_halt_by_id(halt_id: str) -> Optional[HaltItem]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM halts WHERE id = ?", (halt_id,))
            row = cursor.fetchone()
            if not row:
                return None
            score, level, deficits = compute_halt_readiness(
                expected_varkaris=int(row["expected_varkaris"]),
                water_liters=int(row["water_capacity_liters"]),
                food_packets=int(row["food_packets_available"]),
                toilets=int(row["sanitation_facilities"]),
                medical_teams=int(row["medical_teams"]),
                marshals=int(row["crowd_marshals"]),
            )
            return HaltItem(
                id=row["id"],
                name=row["name"],
                dindi_name=row["dindi_name"],
                latitude=float(row["latitude"]),
                longitude=float(row["longitude"]),
                expected_varkaris=int(row["expected_varkaris"]),
                expected_arrival=row["expected_arrival"],
                water_capacity_liters=int(row["water_capacity_liters"]),
                food_packets_available=int(row["food_packets_available"]),
                sanitation_facilities=int(row["sanitation_facilities"]),
                medical_teams=int(row["medical_teams"]),
                crowd_marshals=int(row["crowd_marshals"]),
                readiness_score=score,
                readiness_level=level,
                flagged_deficits=deficits,
                updated_at=row["updated_at"],
            )
        finally:
            conn.close()

    @staticmethod
    def update_readiness(halt_id: str, update_data: HaltReadinessUpdate) -> Optional[HaltItem]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM halts WHERE id = ?", (halt_id,))
            row = cursor.fetchone()
            if not row:
                return None

            water = update_data.water_capacity_liters if update_data.water_capacity_liters is not None else row["water_capacity_liters"]
            food = update_data.food_packets_available if update_data.food_packets_available is not None else row["food_packets_available"]
            toilets = update_data.sanitation_facilities if update_data.sanitation_facilities is not None else row["sanitation_facilities"]
            med = update_data.medical_teams if update_data.medical_teams is not None else row["medical_teams"]
            marshals = update_data.crowd_marshals if update_data.crowd_marshals is not None else row["crowd_marshals"]
            now = datetime.now(timezone.utc).isoformat()

            score, level, deficits = compute_halt_readiness(
                expected_varkaris=int(row["expected_varkaris"]),
                water_liters=water,
                food_packets=food,
                toilets=toilets,
                medical_teams=med,
                marshals=marshals,
            )

            cursor.execute(
                """
                UPDATE halts
                SET water_capacity_liters = ?,
                    food_packets_available = ?,
                    sanitation_facilities = ?,
                    medical_teams = ?,
                    crowd_marshals = ?,
                    readiness_score = ?,
                    readiness_level = ?,
                    updated_at = ?
                WHERE id = ?
                """,
                (water, food, toilets, med, marshals, score, level, now, halt_id),
            )
            conn.commit()

            return HaltItem(
                id=row["id"],
                name=row["name"],
                dindi_name=row["dindi_name"],
                latitude=float(row["latitude"]),
                longitude=float(row["longitude"]),
                expected_varkaris=int(row["expected_varkaris"]),
                expected_arrival=row["expected_arrival"],
                water_capacity_liters=water,
                food_packets_available=food,
                sanitation_facilities=toilets,
                medical_teams=med,
                crowd_marshals=marshals,
                readiness_score=score,
                readiness_level=level,
                flagged_deficits=deficits,
                updated_at=now,
            )
        finally:
            conn.close()
