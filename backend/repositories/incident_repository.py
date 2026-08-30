import uuid
from datetime import datetime, timezone
from typing import List, Optional
from database import get_db_connection
from models.incident import IncidentCreateRequest, IncidentDetail, IncidentResponse


class IncidentRepository:
    @staticmethod
    def create(incident_req: IncidentCreateRequest) -> IncidentResponse:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            short_id = uuid.uuid4().hex[:6].upper()
            is_sos = incident_req.type.lower() == "sos" or incident_req.type.upper().startswith("SOS")
            incident_id = f"SOS-{short_id}" if is_sos else f"INC-{short_id}"
            created_at = datetime.now(timezone.utc).isoformat()
            status = "created"

            cursor.execute(
                """
                INSERT INTO incidents (id, type, severity, description, latitude, longitude, reported_by, status, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    incident_id,
                    incident_req.type,
                    incident_req.severity,
                    incident_req.description or ("Urgent Emergency SOS broadcast triggered by volunteer." if is_sos else ""),
                    incident_req.latitude,
                    incident_req.longitude,
                    incident_req.reported_by or "volunteer_demo",
                    status,
                    created_at,
                ),
            )

            # If SOS or Critical Incident, immediately generate a high-priority alert
            if is_sos or incident_req.severity.upper() == "CRITICAL":
                alt_id = f"ALT-INC-{incident_id}"
                cursor.execute("SELECT COUNT(*) as count FROM alerts WHERE id = ?", (alt_id,))
                if cursor.fetchone()["count"] == 0:
                    cursor.execute(
                        """
                        INSERT INTO alerts (id, title, description, type, severity, location, created_at, is_read)
                        VALUES (?, ?, ?, ?, ?, ?, ?, 0)
                        """,
                        (
                            alt_id,
                            f"EMERGENCY SOS ALERT: {incident_id}",
                            f"Critical SOS broadcast from Sector 4 volunteer ({incident_req.reported_by or 'volunteer_demo'}). Immediate assistance required.",
                            "emergency",
                            "CRITICAL",
                            f"GPS Coordinates ({incident_req.latitude:.4f}, {incident_req.longitude:.4f})",
                            created_at,
                        ),
                    )

            conn.commit()

            return IncidentResponse(
                incident_id=incident_id,
                status=status,
                created_at=created_at,
            )
        finally:
            conn.close()

    @staticmethod
    def get_by_id(incident_id: str) -> Optional[IncidentDetail]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM incidents WHERE id = ?", (incident_id,))
            row = cursor.fetchone()
            if not row:
                return None
            return IncidentDetail(
                id=row["id"],
                type=row["type"],
                severity=row["severity"],
                description=row["description"],
                latitude=row["latitude"],
                longitude=row["longitude"],
                reported_by=row["reported_by"],
                status=row["status"],
                created_at=row["created_at"],
            )
        finally:
            conn.close()

    @staticmethod
    def list_all() -> List[IncidentDetail]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM incidents ORDER BY created_at DESC")
            rows = cursor.fetchall()
            return [
                IncidentDetail(
                    id=row["id"],
                    type=row["type"],
                    severity=row["severity"],
                    description=row["description"],
                    latitude=row["latitude"],
                    longitude=row["longitude"],
                    reported_by=row["reported_by"],
                    status=row["status"],
                    created_at=row["created_at"],
                )
                for row in rows
            ]
        finally:
            conn.close()
