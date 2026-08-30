import uuid
from datetime import datetime, timezone
from typing import List, Optional
from database import get_db_connection
from models.crowd_report import (
    CrowdReportCreateRequest,
    CrowdReportDetail,
    CrowdReportResponse,
    CrowdSummaryResponse,
)


class CrowdReportRepository:
    @staticmethod
    def create(report_req: CrowdReportCreateRequest) -> CrowdReportResponse:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            short_id = uuid.uuid4().hex[:8].upper()
            report_id = f"CRD-{short_id}"
            created_at = datetime.now(timezone.utc).isoformat()
            status = "created"

            cursor.execute(
                """
                INSERT INTO crowd_reports (
                    id, crowd_level, estimated_headcount, movement_direction,
                    description, latitude, longitude, reported_by, created_at
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    report_id,
                    report_req.crowd_level.lower().strip(),
                    report_req.estimated_headcount,
                    report_req.movement_direction,
                    report_req.description or "",
                    report_req.latitude,
                    report_req.longitude,
                    report_req.reported_by or "volunteer_demo",
                    created_at,
                ),
            )
            conn.commit()

            return CrowdReportResponse(
                report_id=report_id,
                status=status,
                created_at=created_at,
            )
        finally:
            conn.close()

    @staticmethod
    def get_by_id(report_id: str) -> Optional[CrowdReportDetail]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM crowd_reports WHERE id = ?", (report_id,))
            row = cursor.fetchone()
            if not row:
                return None
            return CrowdReportDetail(
                id=row["id"],
                crowd_level=row["crowd_level"],
                estimated_headcount=row["estimated_headcount"],
                movement_direction=row["movement_direction"],
                description=row["description"],
                latitude=row["latitude"],
                longitude=row["longitude"],
                reported_by=row["reported_by"],
                created_at=row["created_at"],
            )
        finally:
            conn.close()

    @staticmethod
    def list_all() -> List[CrowdReportDetail]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM crowd_reports ORDER BY created_at DESC")
            rows = cursor.fetchall()
            return [
                CrowdReportDetail(
                    id=row["id"],
                    crowd_level=row["crowd_level"],
                    estimated_headcount=row["estimated_headcount"],
                    movement_direction=row["movement_direction"],
                    description=row["description"],
                    latitude=row["latitude"],
                    longitude=row["longitude"],
                    reported_by=row["reported_by"],
                    created_at=row["created_at"],
                )
                for row in rows
            ]
        finally:
            conn.close()

    @staticmethod
    def get_summary() -> CrowdSummaryResponse:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT crowd_level, COUNT(*) as count FROM crowd_reports GROUP BY crowd_level")
            rows = cursor.fetchall()

            counts = {"normal": 0, "moderate": 0, "high": 0, "critical": 0}
            total = 0
            for row in rows:
                level = row["crowd_level"].lower()
                cnt = row["count"]
                if level in counts:
                    counts[level] = cnt
                total += cnt

            return CrowdSummaryResponse(
                total=total,
                normal=counts["normal"],
                moderate=counts["moderate"],
                high=counts["high"],
                critical=counts["critical"],
            )
        finally:
            conn.close()
