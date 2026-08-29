# SevakConnect Project Structure & Monorepo Architecture

This document describes the unified, production-ready directory structure for the **SevakConnect** ecosystem for the Pandharpur Wari pilgrimage operations.

---

## 1. Top-Level Folder Tree

```
SevakConnect/
│
├── frontend/
│   ├── mobile/                    # Flutter Cross-Platform Mobile & Web App
│   │   ├── lib/                   # Application Core, Models, Services, Screens, Widgets
│   │   │   ├── core/              # Theme, Constants, Extensions
│   │   │   ├── models/            # Domain Data Models
│   │   │   ├── screens/           # Auth & Dashboard Screen Views
│   │   │   ├── services/          # Firebase Auth, Firestore Services
│   │   │   ├── widgets/           # Reusable UI Components
│   │   │   ├── firebase_options.dart
│   │   │   └── main.dart          # Flutter Entrypoint
│   │   ├── web/                   # Web Runner & Assets
│   │   ├── test/                  # Unit & Widget Test Suite
│   │   ├── assets/                # Images & Icons
│   │   ├── pubspec.yaml           # Flutter Dependencies
│   │   └── pubspec.lock
│   │
│   └── android_native/            # Standalone Native Android Jetpack Compose App
│       ├── app/
│       │   ├── src/main/java/com/example/
│       │   │   ├── ApiService.kt
│       │   │   ├── MainActivity.kt
│       │   │   ├── data/          # Models & SevakRepository
│       │   │   └── ui/            # Compose Screens, Navigation, Theme, Components
│       │   ├── src/main/res/      # Layouts, Drawables, Mipmaps, Values, XML
│       │   ├── src/main/AndroidManifest.xml
│       │   ├── src/androidTest/
│       │   ├── src/test/
│       │   ├── build.gradle.kts
│       │   └── proguard-rules.pro
│       ├── gradle/                # Version Catalogs & Wrapper
│       ├── build.gradle.kts
│       ├── settings.gradle.kts
│       ├── gradle.properties
│       ├── gradlew
│       └── gradlew.bat
│
├── backend/                       # FastAPI Backend Service
│   ├── main.py                    # Application Entrypoint & Health Endpoints
│   ├── requirements.txt           # Python Dependencies
│   ├── routers/                   # Modular API Endpoints
│   ├── models/                    # Pydantic Request/Response Models
│   └── services/                  # Business Logic & Firestore Services
│
├── database/                      # Database Schemas & Migrations
│   ├── schema/                    # PostgreSQL & Firestore Table/Collection Schemas
│   ├── migrations/                # Schema Versioning & Migrations
│   └── seed/                      # Initial Database Seeding Scripts
│
├── docs/                          # Project Documentation
│   ├── architecture/
│   │   └── DESIGN.md              # Technical Design Document
│   ├── api/
│   │   └── API_OVERVIEW.md        # API Route Specifications
│   ├── setup/
│   │   └── GETTING_STARTED.md     # Setup & Local Running Guide
│   └── PROJECT_STRUCTURE.md       # Monorepo Structure & File Mapping
│
├── firebase.json                  # Firebase CLI Config & Rules Mapping
├── firestore.rules                # Deployed Security Rules
├── .firebaserc                    # Firebase Project Target (sevakconnect-2026)
├── .env.example                   # Environment Variables Template
├── .gitignore                     # Git Ignore Definitions
└── README.md                      # Repository Root Overview
```

---

## 2. File Migration Inventory

| Component | Source Path | Target Monorepo Location | Status |
| :--- | :--- | :--- | :--- |
| **Flutter Core & UI** | `lib/` | `frontend/mobile/lib/` | ✅ Preserved & Validated |
| **Flutter Web Runner** | `web/` | `frontend/mobile/web/` | ✅ Preserved & Validated |
| **Flutter Tests** | `test/` | `frontend/mobile/test/` | ✅ Preserved (All passed) |
| **Flutter Assets** | `assets/` | `frontend/mobile/assets/` | ✅ Preserved |
| **Flutter Config** | `pubspec.yaml` | `frontend/mobile/pubspec.yaml` | ✅ Preserved |
| **Native Android** | `sevakconnect (2)/` | `frontend/android_native/` | ✅ Preserved & Gradle Synced |
| **FastAPI Backend** | `backend/main.py` | `backend/main.py` | ✅ Preserved & Modularized |
| **Technical Design** | `DESIGN.md` | `docs/architecture/DESIGN.md` | ✅ Preserved |
| **Firebase Rules** | `firestore.rules` | `firestore.rules` | ✅ Preserved (Live Deployed) |
| **Firebase Project** | `.firebaserc` | `.firebaserc` | ✅ Preserved (`sevakconnect-2026`) |

---

## 3. Validation Summary

- **Flutter Dependencies**: `flutter pub get` succeeded with all dependencies resolved.
- **Flutter Code Analysis**: `flutter analyze` $\rightarrow$ **0 issues found!**
- **Flutter Test Suite**: `flutter test` $\rightarrow$ **100% tests passed!**
- **Android Gradle**: `.\gradlew.bat --version` $\rightarrow$ **Gradle 9.3.1 / Kotlin 2.2.21 operational**.
- **Backend Service**: `backend/main.py` verified with FastAPI app title `"SevakConnect Backend"`.
