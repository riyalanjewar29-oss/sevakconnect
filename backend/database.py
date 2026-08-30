import os
import sqlite3
import uuid
from datetime import datetime, timezone
from pathlib import Path

DB_PATH = Path(__file__).resolve().parent / "sevakconnect.db"


def get_db_connection() -> sqlite3.Connection:
    """Provides a SQLite connection with Row factory enabled."""
    conn = sqlite3.connect(str(DB_PATH), check_same_thread=False)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    """Initializes all SQLite database tables and seeds demo operational data if empty."""
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        
        # 1. Incidents table
        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS incidents (
                id TEXT PRIMARY KEY,
                type TEXT NOT NULL,
                severity TEXT NOT NULL,
                description TEXT,
                latitude REAL NOT NULL,
                longitude REAL NOT NULL,
                reported_by TEXT NOT NULL,
                status TEXT NOT NULL,
                created_at TEXT NOT NULL
            )
            """
        )

        # 2. Crowd Reports table
        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS crowd_reports (
                id TEXT PRIMARY KEY,
                crowd_level TEXT NOT NULL,
                estimated_headcount INTEGER,
                movement_direction TEXT,
                description TEXT,
                latitude REAL NOT NULL,
                longitude REAL NOT NULL,
                reported_by TEXT NOT NULL,
                created_at TEXT NOT NULL
            )
            """
        )

        # 3. Supplies table
        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS supplies (
                id TEXT PRIMARY KEY,
                resource TEXT NOT NULL,
                resource_name TEXT NOT NULL,
                quantity INTEGER NOT NULL,
                required_quantity INTEGER NOT NULL,
                unit TEXT NOT NULL,
                location TEXT NOT NULL,
                status TEXT NOT NULL,
                updated_at TEXT NOT NULL
            )
            """
        )

        # 4. Facilities table
        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS facilities (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                type TEXT NOT NULL,
                location_name TEXT NOT NULL,
                latitude REAL NOT NULL,
                longitude REAL NOT NULL,
                status TEXT NOT NULL,
                description TEXT,
                contact_info TEXT,
                updated_at TEXT NOT NULL
            )
            """
        )

        # 5. River Zones table
        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS river_zones (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                marathi_name TEXT,
                latitude REAL NOT NULL,
                longitude REAL NOT NULL,
                current_headcount INTEGER NOT NULL,
                safe_capacity INTEGER NOT NULL,
                water_speed REAL NOT NULL,
                restricted_entry INTEGER NOT NULL,
                density TEXT NOT NULL,
                safety_warning TEXT,
                updated_at TEXT NOT NULL
            )
            """
        )

        # 6. Alerts table
        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS alerts (
                id TEXT PRIMARY KEY,
                title TEXT NOT NULL,
                description TEXT NOT NULL,
                type TEXT NOT NULL,
                severity TEXT NOT NULL,
                location TEXT,
                created_at TEXT NOT NULL,
                is_read INTEGER NOT NULL DEFAULT 0
            )
            """
        )
        # 7. Missing Persons table
        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS missing_persons (
                id TEXT PRIMARY KEY,
                name TEXT,
                age INTEGER,
                gender TEXT,
                description TEXT NOT NULL,
                latitude REAL NOT NULL,
                longitude REAL NOT NULL,
                is_minor INTEGER NOT NULL DEFAULT 0,
                reported_by TEXT NOT NULL,
                additional_info TEXT,
                status TEXT NOT NULL DEFAULT 'OPEN',
                photo_url TEXT,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
            )
            """
        )
        try:
            cursor.execute("ALTER TABLE missing_persons ADD COLUMN photo_url TEXT")
        except Exception:
            pass

        # 8. Halts and Camp Readiness table
        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS halts (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                dindi_name TEXT NOT NULL,
                latitude REAL NOT NULL,
                longitude REAL NOT NULL,
                expected_varkaris INTEGER NOT NULL,
                expected_arrival TEXT NOT NULL,
                water_capacity_liters INTEGER NOT NULL,
                food_packets_available INTEGER NOT NULL,
                sanitation_facilities INTEGER NOT NULL,
                medical_teams INTEGER NOT NULL,
                crowd_marshals INTEGER NOT NULL,
                readiness_score REAL NOT NULL,
                readiness_level TEXT NOT NULL,
                updated_at TEXT NOT NULL
            )
            """
        )

        # 9. Tasks table
        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS tasks (
                id TEXT PRIMARY KEY,
                title TEXT NOT NULL,
                description TEXT NOT NULL,
                priority TEXT NOT NULL,
                status TEXT NOT NULL,
                assigned_to TEXT NOT NULL,
                location_name TEXT NOT NULL,
                latitude REAL,
                longitude REAL,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
            )
            """
        )
        conn.commit()

        # Seed initial Demo Supplies if table is empty
        cursor.execute("SELECT COUNT(*) as count FROM supplies")
        if cursor.fetchone()["count"] == 0:
            now = datetime.now(timezone.utc).isoformat()
            demo_supplies = [
                ("SUP-WAT-001", "water", "Drinking Water", 350, 500, "Liters", "Wakhari Phata", "LOW", now),
                ("SUP-MED-001", "medical", "Medical Kits", 3, 15, "Kits", "Wakhari Phata", "CRITICAL", now),
                ("SUP-MEA-001", "food", "Meals / Ration", 1200, 1000, "Packets", "Wakhari Phata", "AVAILABLE", now),
                ("SUP-WAT-002", "water", "Drinking Water", 1800, 2000, "Liters", "Bhakti Marg Checkpoint", "AVAILABLE", now),
                ("SUP-MED-002", "medical", "Medical Kits", 12, 10, "Kits", "Bhakti Marg Checkpoint", "AVAILABLE", now),
                ("SUP-MEA-002", "food", "Meals / Ration", 400, 800, "Packets", "Bhakti Marg Checkpoint", "LOW", now),
                ("SUP-WAT-003", "water", "Drinking Water", 100, 600, "Liters", "Chandrabhaga River Ghat", "CRITICAL", now),
            ]
            cursor.executemany(
                """
                INSERT INTO supplies (id, resource, resource_name, quantity, required_quantity, unit, location, status, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                demo_supplies,
            )
            conn.commit()

        # Seed initial Demo Facilities if table is empty
        cursor.execute("SELECT COUNT(*) as count FROM facilities")
        if cursor.fetchone()["count"] == 0:
            now = datetime.now(timezone.utc).isoformat()
            demo_facilities = [
                # 3 Medical
                ("FAC-MED-001", "Wakhari Emergency Medical Tent 1", "medical", "Wakhari Phata", 17.7015, 75.2905, "OPEN", "24/7 volunteer doctors, first aid & dehydration kits.", "Dr. Deshmukh (Sevak #12)", now),
                ("FAC-MED-002", "Pandharpur Station Medical Camp", "medical", "Station Road", 17.6750, 75.3230, "OPEN", "Emergency triage, heatstroke beds, and ambulance dispatch.", "Red Cross Camp", now),
                ("FAC-MED-003", "Ghat Medical Post", "medical", "Chandrabhaga Ghat", 17.6715, 75.3215, "LIMITED", "Basic bandages, ORS distribution, and blister care.", "Sevak First Aid", now),
                # 2 Water
                ("FAC-WAT-001", "Wakhari Clean Drinking Water Kiosk", "water", "Wakhari Phata", 17.7022, 75.2910, "AVAILABLE", "Continuous RO filtered drinking water tanker.", "Jal Seva Trust", now),
                ("FAC-WAT-002", "Bhakti Marg Water Tanker Point", "water", "Bhakti Marg", 17.6742, 75.3265, "AVAILABLE", "5000L cold water storage barrels.", "Nagar Palika", now),
                # 2 Toilets
                ("FAC-TOI-001", "Wakhari Mobile Toilet Complex", "toilets", "Wakhari Phata", 17.7025, 75.2895, "AVAILABLE", "10 bio-toilets with continuous sanitation staff.", "Swachh Bharat Team", now),
                ("FAC-TOI-002", "Riverbank Sanitation Block", "toilets", "Chandrabhaga Ghat", 17.6708, 75.3225, "LIMITED", "Mobile sanitation units near ghat entrance.", "Sevak Sanitation", now),
                # 1 Food
                ("FAC-FOO-001", "Annadaan Palkhi Bhojan Tent", "food", "Wakhari Phata", 17.7010, 75.2920, "OPEN", "Fresh hot Mahaprasad for warkaris 06:00 - 22:00.", "Annadaan Samiti", now),
                # 1 Security
                ("FAC-SEC-001", "Volunteer & Police Assistance Post", "security", "Bhakti Marg Chowk", 17.6745, 75.3255, "OPEN", "Lost & Found desk, crowd monitoring, and safety assistance.", "Pandharpur City Police & Sevaks", now),
            ]
            cursor.executemany(
                """
                INSERT INTO facilities (id, name, type, location_name, latitude, longitude, status, description, contact_info, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                demo_facilities,
            )
            conn.commit()

        # Seed initial Demo River Zones if table is empty
        cursor.execute("SELECT COUNT(*) as count FROM river_zones")
        if cursor.fetchone()["count"] == 0:
            now = datetime.now(timezone.utc).isoformat()
            demo_zones = [
                ("RIV-ZN-001", "Ghat South Snan Sector", "दक्षिण स्नान घाट", 17.6698, 75.3218, 1400, 3000, 1.2, 0, "normal", "Bathing cordon operational. Lifeguard boat on patrol.", now),
                ("RIV-ZN-002", "Main Pundalik Temple Ghat", "पुंडलिक मंदिर घाट", 17.6715, 75.3235, 4200, 5000, 1.8, 0, "heavy", "High footfall near temple steps. Follow marked queues.", now),
                ("RIV-ZN-003", "Deep Water Channel Sandbar", "खोल पाण्याचा प्रवाह", 17.6742, 75.3268, 2600, 2000, 3.4, 1, "critical", "Entry prohibited beyond red flags due to strong undercurrent.", now),
                ("RIV-ZN-004", "North Sandbed Resting Ghat", "उत्तर वाळवंट घाट", 17.6775, 75.3285, 2200, 3500, 0.9, 0, "moderate", "Shaded resting shelters open with clean drinking water points.", now),
            ]
            cursor.executemany(
                """
                INSERT INTO river_zones (id, name, marathi_name, latitude, longitude, current_headcount, safe_capacity, water_speed, restricted_entry, density, safety_warning, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                demo_zones,
            )
            conn.commit()

        # Seed initial Demo Alerts if table is empty
        cursor.execute("SELECT COUNT(*) as count FROM alerts")
        if cursor.fetchone()["count"] == 0:
            now = datetime.now(timezone.utc).isoformat()
            demo_alerts = [
                ("ALT-RIV-001", "River Zone 3 Entry Restricted", "Deep Water Channel sandbar closed due to 3.4 m/s undercurrent and red flag deployment.", "river_safety", "CRITICAL", "Chandrabhaga Deep Water Sandbar", now, 0),
                ("ALT-CRW-001", "High Crowd Surge at Wakhari Phata", "Dense warkari movement approaching bottleneck. Volunteers redirecting non-palkhi vehicles.", "crowd", "HIGH", "Wakhari Phata Corridor", now, 0),
                ("ALT-SUP-001", "Medical Kits Running Low", "Only 3 first-aid kits remaining at Wakhari Medical Tent 1. Restock requested from Central Hub.", "supply", "WARNING", "Wakhari Phata", now, 0),
                ("ALT-GEN-001", "Hydration Kiosk Restocked", "5,000L cold water tanker arrived at Bhakti Marg Point.", "general", "INFO", "Bhakti Marg", now, 1),
            ]
            cursor.executemany(
                """
                INSERT INTO alerts (id, title, description, type, severity, location, created_at, is_read)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """,
                demo_alerts,
            )
            conn.commit()

        # Seed initial Demo Missing Persons if table is empty
        cursor.execute("SELECT COUNT(*) as count FROM missing_persons")
        if cursor.fetchone()["count"] == 0:
            now = datetime.now(timezone.utc).isoformat()
            demo_missing = [
                ("MP-1001", "Aarav Shinde", 8, "Male", "Wearing yellow kurta and white topi. Lost contact near Wakhari food distribution stall.", 17.7015, 75.2910, 1, "volunteer_demo", "Carrying small steel water bottle.", "SEARCHING", now, now),
                ("MP-1002", "Gangubai Patil", 72, "Female", "Elderly woman in green saree with Tulsi mala. Does not speak Hindi, Marathi only.", 17.6745, 75.3255, 0, "volunteer_demo", "Walking with wooden cane.", "OPEN", now, now),
                ("MP-1003", "Rohan Gaikwad", 14, "Male", "Blue t-shirt and jeans. Last seen near Bhakti Marg Medical post.", 17.6750, 75.3230, 1, "volunteer_demo", "Reunited with Dindi #4 pramukh.", "FOUND", now, now),
            ]
            cursor.executemany(
                """
                INSERT INTO missing_persons (id, name, age, gender, description, latitude, longitude, is_minor, reported_by, additional_info, status, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                demo_missing,
            )
            conn.commit()

        # Seed initial Demo Halts if table is empty
        cursor.execute("SELECT COUNT(*) as count FROM halts")
        if cursor.fetchone()["count"] == 0:
            now = datetime.now(timezone.utc).isoformat()
            demo_halts = [
                ("HLT-WAK-001", "Wakhari Phata", "Sant Dnyaneshwar Maharaj Dindi 1", 17.7015, 75.2905, 5000, "14:30 HRS", 15000, 5000, 50, 3, 20, 100.0, "READY", now),
                ("HLT-MAL-002", "Malwadi Halt", "Sant Tukaram Maharaj Dindi 2", 17.6850, 75.3100, 6000, "17:00 HRS", 9000, 6000, 30, 2, 12, 60.5, "MODERATE", now),
                ("HLT-PAN-003", "Pandharpur Entry Halt", "All Combined Palkhi Dindis", 17.6775, 75.3285, 10000, "20:00 HRS", 6000, 2000, 15, 1, 5, 18.2, "NOT READY", now),
            ]
            cursor.executemany(
                """
                INSERT INTO halts (id, name, dindi_name, latitude, longitude, expected_varkaris, expected_arrival, water_capacity_liters, food_packets_available, sanitation_facilities, medical_teams, crowd_marshals, readiness_score, readiness_level, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                demo_halts,
            )
            conn.commit()

        # Seed initial Demo Tasks if table is empty
        cursor.execute("SELECT COUNT(*) as count FROM tasks")
        if cursor.fetchone()["count"] == 0:
            now = datetime.now(timezone.utc).isoformat()
            demo_tasks = [
                ("TSK-MED-001", "Check Medical Camp", "Verify first aid kits, emergency stretcher, and doctor availability at Tent 2.", "HIGH", "PENDING", "volunteer_demo", "Wakhari Phata", 17.6830, 75.3190, now, now),
                ("TSK-WAT-002", "Verify Water Supply", "Inspect water tanker refill levels and community tap pressure.", "MEDIUM", "IN PROGRESS", "volunteer_demo", "Malwadi Halt", 17.6540, 75.3210, now, now),
                ("TSK-CRW-003", "Crowd Checkpoint Support", "Assist crowd marshals at Sector 4 barricade bottleneck.", "HIGH", "PENDING", "volunteer_demo", "Pandharpur Entry Checkpoint", 17.6750, 75.3240, now, now),
                ("TSK-SAN-004", "Sanitation Check", "Inspect mobile toilet cleanliness, water availability, and hygiene supply stock.", "LOW", "COMPLETED", "volunteer_demo", "Pandharpur Entry Checkpoint", 17.6750, 75.3240, now, now),
            ]
            cursor.executemany(
                """
                INSERT INTO tasks (id, title, description, priority, status, assigned_to, location_name, latitude, longitude, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                demo_tasks,
            )
            conn.commit()

    finally:
        conn.close()


