import uuid
from datetime import datetime, timezone
from typing import List, Optional
from database import get_db_connection
from models.supply import SupplyItem, SupplyUpdateRequest


def calculate_supply_status(quantity: int, required_quantity: int) -> str:
    """Centralized calculation for supply status thresholds."""
    if quantity >= required_quantity:
        return "AVAILABLE"
    elif quantity >= int(required_quantity * 0.4):
        return "LOW"
    else:
        return "CRITICAL"


def get_default_resource_details(resource: str):
    res_lower = resource.lower().strip()
    if "water" in res_lower:
        return "water", "Drinking Water", "Liters", 500
    elif "food" in res_lower or "meal" in res_lower:
        return "food", "Meals / Ration", "Packets", 1000
    elif "med" in res_lower:
        return "medical", "Medical Kits", "Kits", 15
    else:
        return res_lower, res_lower.capitalize(), "Units", 100


class SupplyRepository:
    @staticmethod
    def get_all(location: Optional[str] = None) -> List[SupplyItem]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            if location:
                cursor.execute(
                    "SELECT * FROM supplies WHERE location = ? ORDER BY resource_name ASC",
                    (location,),
                )
            else:
                cursor.execute("SELECT * FROM supplies ORDER BY location ASC, resource_name ASC")
            rows = cursor.fetchall()
            return [
                SupplyItem(
                    id=row["id"],
                    resource=row["resource"],
                    resource_name=row["resource_name"],
                    quantity=row["quantity"],
                    required_quantity=row["required_quantity"],
                    unit=row["unit"],
                    location=row["location"],
                    status=row["status"],
                    updated_at=row["updated_at"],
                )
                for row in rows
            ]
        finally:
            conn.close()

    @staticmethod
    def update_or_create(req: SupplyUpdateRequest) -> SupplyItem:
        res_key, default_name, default_unit, default_req = get_default_resource_details(req.resource)
        unit = req.unit or default_unit
        req_qty = req.required_quantity if req.required_quantity is not None else default_req
        status = calculate_supply_status(req.quantity, req_qty)
        now = datetime.now(timezone.utc).isoformat()

        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            # Check if supply record exists for this resource and location
            cursor.execute(
                "SELECT * FROM supplies WHERE resource = ? AND location = ?",
                (res_key, req.location),
            )
            existing = cursor.fetchone()

            if existing:
                supply_id = existing["id"]
                cursor.execute(
                    """
                    UPDATE supplies
                    SET quantity = ?, required_quantity = ?, unit = ?, status = ?, updated_at = ?
                    WHERE id = ?
                    """,
                    (req.quantity, req_qty, unit, status, now, supply_id),
                )
            else:
                supply_id = f"SUP-{res_key[:3].upper()}-{uuid.uuid4().hex[:6].upper()}"
                cursor.execute(
                    """
                    INSERT INTO supplies (id, resource, resource_name, quantity, required_quantity, unit, location, status, updated_at)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    (supply_id, res_key, default_name, req.quantity, req_qty, unit, req.location, status, now),
                )
            conn.commit()

            cursor.execute("SELECT * FROM supplies WHERE id = ?", (supply_id,))
            row = cursor.fetchone()
            return SupplyItem(
                id=row["id"],
                resource=row["resource"],
                resource_name=row["resource_name"],
                quantity=row["quantity"],
                required_quantity=row["required_quantity"],
                unit=row["unit"],
                location=row["location"],
                status=row["status"],
                updated_at=row["updated_at"],
            )
        finally:
            conn.close()
