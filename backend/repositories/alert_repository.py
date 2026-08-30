import uuid
from datetime import datetime, timezone
from typing import List, Optional
from database import get_db_connection
from models.alert import AlertItem


class AlertRepository:
    """Repository handling SQLite database interactions for Operational Alerts."""

    @staticmethod
    def _severity_sort_order(severity: str) -> int:
        mapping = {
            "CRITICAL": 0,
            "HIGH": 1,
            "WARNING": 2,
            "INFO": 3,
        }
        return mapping.get(severity.upper(), 4)

    @staticmethod
    def get_all_alerts(unread_only: bool = False, severity: Optional[str] = None) -> List[AlertItem]:
        """Retrieves alerts with operational priority ordering."""
        # First ensure operational sync
        AlertRepository.sync_operational_alerts()

        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            query = "SELECT id, title, description, type, severity, location, created_at, is_read FROM alerts WHERE 1=1"
            params = []

            if unread_only:
                query += " AND is_read = 0"
            if severity:
                query += " AND UPPER(severity) = UPPER(?)"
                params.append(severity)

            query += """
                ORDER BY 
                    CASE UPPER(severity)
                        WHEN 'CRITICAL' THEN 0
                        WHEN 'HIGH' THEN 1
                        WHEN 'WARNING' THEN 2
                        WHEN 'INFO' THEN 3
                        ELSE 4
                    END ASC,
                    created_at DESC
            """
            cursor.execute(query, params)
            rows = cursor.fetchall()
            return [
                AlertItem(
                    id=row["id"],
                    title=row["title"],
                    description=row["description"],
                    type=row["type"],
                    severity=row["severity"].upper(),
                    location=row["location"] or "",
                    created_at=row["created_at"],
                    is_read=bool(row["is_read"]),
                )
                for row in rows
            ]
        finally:
            conn.close()

    @staticmethod
    def mark_as_read(alert_id: str) -> Optional[AlertItem]:
        """Marks an alert as read in SQLite and returns updated item."""
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.execute(
                "UPDATE alerts SET is_read = 1 WHERE id = ?",
                (alert_id,),
            )
            conn.commit()

            cursor.execute(
                "SELECT id, title, description, type, severity, location, created_at, is_read FROM alerts WHERE id = ?",
                (alert_id,),
            )
            row = cursor.fetchone()
            if not row:
                return None
            return AlertItem(
                id=row["id"],
                title=row["title"],
                description=row["description"],
                type=row["type"],
                severity=row["severity"].upper(),
                location=row["location"] or "",
                created_at=row["created_at"],
                is_read=bool(row["is_read"]),
            )
        finally:
            conn.close()

    @staticmethod
    def create_alert(
        title: str,
        description: str,
        type: str,
        severity: str,
        location: str = "",
    ) -> AlertItem:
        """Inserts a new operational alert."""
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            alert_id = f"ALT-{type[:3].upper()}-{uuid.uuid4().hex[:6].upper()}"
            now = datetime.now(timezone.utc).isoformat()

            cursor.execute(
                """
                INSERT INTO alerts (id, title, description, type, severity, location, created_at, is_read)
                VALUES (?, ?, ?, ?, ?, ?, ?, 0)
                """,
                (alert_id, title, description, type, severity.upper(), location, now),
            )
            conn.commit()
            return AlertItem(
                id=alert_id,
                title=title,
                description=description,
                type=type,
                severity=severity.upper(),
                location=location,
                created_at=now,
                is_read=False,
            )
        finally:
            conn.close()

    @staticmethod
    def sync_operational_alerts():
        """
        Scans other operational tables (crowd_reports, river_zones, incidents)
        to generate actionable alerts for high/critical events if not already alerted.
        """
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            now = datetime.now(timezone.utc).isoformat()

            # 1. Sync Critical Incidents
            cursor.execute("SELECT id, type, severity, description, created_at FROM incidents WHERE UPPER(severity) IN ('CRITICAL', 'HIGH')")
            incidents = cursor.fetchall()
            for inc in incidents:
                alt_id = f"ALT-INC-{inc['id']}"
                cursor.execute("SELECT COUNT(*) as count FROM alerts WHERE id = ?", (alt_id,))
                if cursor.fetchone()["count"] == 0:
                    cursor.execute(
                        """
                        INSERT INTO alerts (id, title, description, type, severity, location, created_at, is_read)
                        VALUES (?, ?, ?, ?, ?, ?, ?, 0)
                        """,
                        (
                            alt_id,
                            f"Emergency Alert: {inc['type']}",
                            inc['description'] or f"High severity {inc['type']} reported.",
                            "emergency",
                            inc['severity'].upper(),
                            "Palkhi Route",
                            inc['created_at'],
                        ),
                    )

            # 2. Sync Restricted / Critical River Zones
            cursor.execute("SELECT id, name, marathi_name, water_speed, restricted_entry, safety_warning, updated_at FROM river_zones WHERE restricted_entry = 1")
            restricted_zones = cursor.fetchall()
            for rz in restricted_zones:
                alt_id = f"ALT-RIV-{rz['id']}"
                cursor.execute("SELECT COUNT(*) as count FROM alerts WHERE id = ?", (alt_id,))
                if cursor.fetchone()["count"] == 0:
                    cursor.execute(
                        """
                        INSERT INTO alerts (id, title, description, type, severity, location, created_at, is_read)
                        VALUES (?, ?, ?, ?, ?, ?, ?, 0)
                        """,
                        (
                            alt_id,
                            f"River Safety Warning: {rz['name']}",
                            rz['safety_warning'] or f"Entry restricted due to {rz['water_speed']} m/s water flow speed.",
                            "river_safety",
                            "CRITICAL",
                            rz['name'],
                            rz['updated_at'],
                        ),
                    )

            # 3. Sync High / Critical Crowd Reports
            cursor.execute("SELECT id, crowd_level, description, created_at FROM crowd_reports WHERE UPPER(crowd_level) IN ('CRITICAL', 'HIGH', 'HEAVY')")
            crowd_reports = cursor.fetchall()
            for cr in crowd_reports:
                alt_id = f"ALT-CRW-{cr['id']}"
                cursor.execute("SELECT COUNT(*) as count FROM alerts WHERE id = ?", (alt_id,))
                if cursor.fetchone()["count"] == 0:
                    sev = "CRITICAL" if cr["crowd_level"].upper() == "CRITICAL" else "HIGH"
                    cursor.execute(
                        """
                        INSERT INTO alerts (id, title, description, type, severity, location, created_at, is_read)
                        VALUES (?, ?, ?, ?, ?, ?, ?, 0)
                        """,
                        (
                            alt_id,
                            f"Crowd Surge Warning ({sev})",
                            cr['description'] or "Dense crowd buildup observed. Corridor redirection recommended.",
                            "crowd",
                            sev,
                            "Wari Corridor",
                            cr['created_at'],
                        ),
                    )

            conn.commit()
        except Exception:
            pass
        finally:
            conn.close()
