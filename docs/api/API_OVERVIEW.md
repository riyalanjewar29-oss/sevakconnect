# SevakConnect API Overview

## Base URL
- Local: `http://127.0.0.1:8000`
- Android Emulator: `http://10.0.2.2:8000`

---

## Core Endpoints

### 1. Root
- **Method**: `GET /`
- **Response**:
  ```json
  {
    "message": "SevakConnect backend is running"
  }
  ```

### 2. Health Check
- **Method**: `GET /health`
- **Response**:
  ```json
  {
    "status": "ok",
    "message": "SevakConnect backend is connected"
  }
  ```

---

## Planned Service Routers

- `/emergencies`: Real-time incident alerts and resolution tracking
- `/crowd`: Crowd density reports and zone status
- `/lost-found`: Missing persons and children reports
- `/zones`: Chandrabhaga river zone flood and density monitoring
