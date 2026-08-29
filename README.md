# SevakConnect

> **Operational Command & Crowd Safety Platform for the Pandharpur Wari Pilgrimage**

---

## 🏛️ Monorepo Overview

| Subproject | Path | Description | Tech Stack |
| :--- | :--- | :--- | :--- |
| **Flutter App** | [`frontend/mobile/`](./frontend/mobile) | Cross-platform mobile and web operations dashboard | Flutter, Dart, Firebase |
| **Native Android** | [`frontend/android_native/`](./frontend/android_native) | Native Android Jetpack Compose field volunteer app | Kotlin, Jetpack Compose |
| **Backend** | [`backend/`](./backend) | High-performance RESTful API backend service | FastAPI, Python, Uvicorn |
| **Database** | [`database/`](./database) | Database schemas, migrations, and seed scripts | PostgreSQL / Firestore |
| **Documentation** | [`docs/`](./docs) | Architecture, API specs, and setup instructions | Markdown |

---

## 🚀 Quick Start

### 1. Flutter Mobile / Web
```powershell
cd frontend/mobile
flutter pub get
flutter run -d chrome
```

### 2. Native Android App
Open `frontend/android_native` in Android Studio or build with:
```powershell
cd frontend/android_native
.\gradlew.bat assembleDebug
```

### 3. FastAPI Backend
```powershell
cd backend
pip install -r requirements.txt
python -m uvicorn main:app --reload
```

---

## 📖 Documentation

- [Project Architecture & Directory Tree](./docs/PROJECT_STRUCTURE.md)
- [Technical Design Specifications](./docs/architecture/DESIGN.md)
- [API Route Specifications](./docs/api/API_OVERVIEW.md)
- [Developer Setup Guide](./docs/setup/GETTING_STARTED.md)
