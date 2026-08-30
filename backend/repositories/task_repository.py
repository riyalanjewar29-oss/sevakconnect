import uuid
from datetime import datetime, timezone
from typing import List, Optional
from database import get_db_connection
from models.task import TaskItem, TaskCreate


class TaskRepository:
    """Repository handling SQLite database operations for Tasks."""

    @staticmethod
    def get_all_tasks(status: Optional[str] = None) -> List[TaskItem]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            query = "SELECT * FROM tasks WHERE 1=1"
            params = []
            if status and status.upper() != "ALL":
                query += " AND UPPER(status) = UPPER(?)"
                params.append(status)
            
            query += """
                ORDER BY
                    CASE UPPER(priority)
                        WHEN 'CRITICAL' THEN 0
                        WHEN 'HIGH' THEN 1
                        WHEN 'MEDIUM' THEN 2
                        WHEN 'LOW' THEN 3
                        ELSE 4
                    END ASC,
                    CASE UPPER(status)
                        WHEN 'IN PROGRESS' THEN 0
                        WHEN 'PENDING' THEN 1
                        WHEN 'COMPLETED' THEN 2
                        ELSE 3
                    END ASC,
                    created_at DESC
            """
            cursor.execute(query, params)
            rows = cursor.fetchall()
            return [
                TaskItem(
                    id=row["id"],
                    title=row["title"],
                    description=row["description"],
                    priority=row["priority"].upper(),
                    status=row["status"].upper(),
                    assigned_to=row["assigned_to"],
                    location_name=row["location_name"],
                    latitude=float(row["latitude"]) if row["latitude"] is not None else None,
                    longitude=float(row["longitude"]) if row["longitude"] is not None else None,
                    created_at=row["created_at"],
                    updated_at=row["updated_at"],
                )
                for row in rows
            ]
        finally:
            conn.close()

    @staticmethod
    def get_task_by_id(task_id: str) -> Optional[TaskItem]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM tasks WHERE id = ?", (task_id,))
            row = cursor.fetchone()
            if not row:
                return None
            return TaskItem(
                id=row["id"],
                title=row["title"],
                description=row["description"],
                priority=row["priority"].upper(),
                status=row["status"].upper(),
                assigned_to=row["assigned_to"],
                location_name=row["location_name"],
                latitude=float(row["latitude"]) if row["latitude"] is not None else None,
                longitude=float(row["longitude"]) if row["longitude"] is not None else None,
                created_at=row["created_at"],
                updated_at=row["updated_at"],
            )
        finally:
            conn.close()

    @staticmethod
    def update_task_status(task_id: str, new_status: str) -> Optional[TaskItem]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            now = datetime.now(timezone.utc).isoformat()
            cursor.execute(
                "UPDATE tasks SET status = ?, updated_at = ? WHERE id = ?",
                (new_status.upper(), now, task_id),
            )
            conn.commit()
            return TaskRepository.get_task_by_id(task_id)
        finally:
            conn.close()

    @staticmethod
    def create_task(data: TaskCreate) -> TaskItem:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            task_id = f"TSK-{uuid.uuid4().hex[:6].upper()}"
            now = datetime.now(timezone.utc).isoformat()
            cursor.execute(
                """
                INSERT INTO tasks (
                    id, title, description, priority, status, assigned_to,
                    location_name, latitude, longitude, created_at, updated_at
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    task_id,
                    data.title,
                    data.description,
                    data.priority.upper(),
                    data.status.upper(),
                    data.assigned_to,
                    data.location_name,
                    data.latitude,
                    data.longitude,
                    now,
                    now,
                ),
            )
            conn.commit()
            return TaskRepository.get_task_by_id(task_id)
        finally:
            conn.close()
