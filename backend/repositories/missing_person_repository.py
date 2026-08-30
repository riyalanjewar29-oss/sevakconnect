import random
from datetime import datetime, timezone
from typing import List, Optional
from database import get_db_connection
from models.missing_person import MissingPersonCreate, MissingPersonItem, MissingPersonCreateResponse
from repositories.alert_repository import AlertRepository


class MissingPersonRepository:
    """Repository handling SQLite database interactions for Missing Persons."""

    @staticmethod
    def create_case(data: MissingPersonCreate) -> MissingPersonCreateResponse:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            case_id = f"MP-{random.randint(1000, 9999)}"
            now = datetime.now(timezone.utc).isoformat()

            cursor.execute(
                """
                INSERT INTO missing_persons (
                    id, name, age, gender, description, latitude, longitude,
                    is_minor, reported_by, additional_info, status, photo_url, created_at, updated_at
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'OPEN', ?, ?, ?)
                """,
                (
                    case_id,
                    data.name,
                    data.age,
                    data.gender,
                    data.description,
                    data.latitude,
                    data.longitude,
                    1 if data.is_minor else 0,
                    data.reported_by or "volunteer_demo",
                    data.additional_info,
                    data.photo_url,
                    now,
                    now,
                ),
            )
            conn.commit()

            alert_created = False
            # If minor, trigger high-priority operational alert immediately
            if data.is_minor:
                person_label = data.name if data.name else "Unidentified child"
                age_str = f" ({data.age} yrs)" if data.age else ""
                AlertRepository.create_alert(
                    title=f"Missing Minor Alert: {person_label}{age_str}",
                    description=f"Minor reported missing. {data.description}. Case: {case_id}",
                    type="missing_person",
                    severity="CRITICAL",
                    location=f"Coordinates ({data.latitude:.4f}, {data.longitude:.4f})",
                )
                alert_created = True

            return MissingPersonCreateResponse(
                case_id=case_id,
                status="reported",
                created_at=now,
                alert_created=alert_created,
            )
        finally:
            conn.close()

    @staticmethod
    def get_all_cases(status: Optional[str] = None) -> List[MissingPersonItem]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            query = "SELECT * FROM missing_persons WHERE 1=1"
            params = []
            if status and status.upper() != "ALL":
                query += " AND UPPER(status) = UPPER(?)"
                params.append(status)
            query += " ORDER BY created_at DESC"

            cursor.execute(query, params)
            rows = cursor.fetchall()
            return [
                MissingPersonItem(
                    id=row["id"],
                    name=row["name"],
                    age=row["age"],
                    gender=row["gender"],
                    description=row["description"],
                    latitude=float(row["latitude"]),
                    longitude=float(row["longitude"]),
                    is_minor=bool(row["is_minor"]),
                    reported_by=row["reported_by"],
                    additional_info=row["additional_info"],
                    status=row["status"].upper(),
                    photo_url=row["photo_url"] if "photo_url" in row.keys() else None,
                    created_at=row["created_at"],
                    updated_at=row["updated_at"],
                )
                for row in rows
            ]
        finally:
            conn.close()

    @staticmethod
    def get_case_by_id(case_id: str) -> Optional[MissingPersonItem]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM missing_persons WHERE id = ?", (case_id,))
            row = cursor.fetchone()
            if not row:
                return None
            return MissingPersonItem(
                id=row["id"],
                name=row["name"],
                age=row["age"],
                gender=row["gender"],
                description=row["description"],
                latitude=float(row["latitude"]),
                longitude=float(row["longitude"]),
                is_minor=bool(row["is_minor"]),
                reported_by=row["reported_by"],
                additional_info=row["additional_info"],
                status=row["status"].upper(),
                photo_url=row["photo_url"] if "photo_url" in row.keys() else None,
                created_at=row["created_at"],
                updated_at=row["updated_at"],
            )
        finally:
            conn.close()
