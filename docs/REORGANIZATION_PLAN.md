# SevakConnect Monorepo Reorganization Plan

---

## 1. Current Workspace Structure

```
SevakConnect/
│
├── frontend/
│   ├── mobile/                    # Flutter project copy (lib/, web/, test/, assets/, pubspec.yaml)
│   └── android_native/            # Standalone Native Android Jetpack Compose project
│
├── backend/                       # FastAPI backend (main.py, requirements.txt, routers/, models/, services/)
├── database/                      # database/ (schema/, migrations/, seed/)
├── admin_dashboard/               # Admin dashboard documentation/pointer
├── docs/                          # docs/ (architecture/, api/, setup/, PROJECT_STRUCTURE.md)
│
├── lib/                           # Root-level legacy Flutter source (duplicate of frontend/mobile/lib)
├── web/                           # Root-level legacy Flutter web runner (duplicate of frontend/mobile/web)
├── test/                          # Root-level legacy Flutter test (duplicate of frontend/mobile/test)
├── assets/                        # Root-level assets
├── pubspec.yaml                   # Root-level pubspec.yaml
├── pubspec.lock                   # Root-level pubspec.lock
│
├── app/                           # Root-level legacy Android harness
├── gradle/                        # Root-level legacy Gradle wrapper
├── build.gradle.kts               # Root-level legacy build.gradle.kts
├── settings.gradle.kts            # Root-level legacy settings.gradle.kts
├── gradle.properties              # Root-level legacy gradle.properties
│
├── sevakconnect (2)/              # Empty directory leftover from move
│
├── firebase.json                  # Firebase configuration
├── firestore.rules                # Deployed Firestore security rules
├── .firebaserc                    # Firebase project identifier
├── .env.example
├── .gitignore
├── DESIGN.md
└── README.md
```

---

## 2. Proposed Target Structure

```
SevakConnect/
│
├── frontend/
│   ├── mobile/                    # Flutter Cross-Platform Mobile & Web Project
│   │   ├── lib/                   # Flutter Application (screens, services, models, widgets)
│   │   ├── assets/                # Visual assets & images
│   │   ├── web/                   # Flutter Web runner
│   │   ├── test/                  # Automated test suite
│   │   ├── pubspec.yaml           # Flutter dependencies & metadata
│   │   └── pubspec.lock
│   │
│   └── native_android/            # Standalone Native Android Jetpack Compose Project
│       ├── app/
│       │   ├── src/main/java/com/example/ (MainActivity.kt, ApiService.kt, data, ui)
│       │   ├── src/main/res/
│       │   ├── src/main/AndroidManifest.xml
│       │   ├── src/androidTest/
│       │   ├── src/test/
│       │   └── build.gradle.kts
│       ├── gradle/
│       │   ├── libs.versions.toml
│       │   └── wrapper/
│       ├── build.gradle.kts
│       ├── settings.gradle.kts
│       ├── gradle.properties
│       ├── gradlew
│       └── gradlew.bat
│
├── backend/                       # FastAPI Backend Service
│   ├── app/
│   │   ├── api/                   # REST API routes
│   │   ├── models/                # Pydantic data schemas
│   │   ├── services/              # Business logic & Firebase services
│   │   ├── database/              # Database connection & session management
│   │   └── main.py                # FastAPI entrypoint
│   ├── tests/                     # Backend test suite
│   └── requirements.txt           # Python dependencies
│
├── database/                      # PostgreSQL / Firestore Schemas & Migrations
│   ├── schema/
│   ├── migrations/
│   └── seed/
│
├── docs/                          # Project Documentation
│   ├── architecture/
│   │   └── DESIGN.md
│   ├── api/
│   │   └── API_OVERVIEW.md
│   ├── setup/
│   │   └── GETTING_STARTED.md
│   ├── PROJECT_STRUCTURE.md
│   ├── REORGANIZATION_PLAN.md
│   └── REORGANIZATION_REPORT.md
│
├── scripts/                       # Developer automation scripts
├── tests/                         # End-to-end and integration tests
├── README.md                      # Monorepo overview
├── DESIGN.md                      # System design document
└── .gitignore                     # Monorepo gitignore rules
```

---

## 3. Duplicate Files & Suspicious Directories Analysis

1. **`sevakconnect (2)/`**:
   - Status: Empty directory.
   - Action: Clean up empty directory container.
2. **`frontend/android_native/` $\rightarrow$ `frontend/native_android/`**:
   - Status: Rename folder to match user's requested naming convention `frontend/native_android/`.
3. **`lib/`, `web/`, `test/`, `assets/`, `pubspec.yaml`, `pubspec.lock`**:
   - Status: Identical content exists in `frontend/mobile/`.
   - Action: `frontend/mobile/` is the canonical Flutter project location.
4. **`app/`, `build.gradle.kts`, `settings.gradle.kts`, `gradle/` (Root)**:
   - Status: Identical content exists in `frontend/native_android/`.
   - Action: `frontend/native_android/` is the canonical native Android project location.
5. **`backend/` modularization**:
   - Action: Transition `backend/main.py` into `backend/app/main.py` with `backend/app/api/`, `backend/app/models/`, `backend/app/services/`, and `backend/app/database/`.

---

## 4. Old Path $\rightarrow$ New Path Mapping

| Current Location | Target Location | Subproject / Role |
| :--- | :--- | :--- |
| `frontend/android_native/` | `frontend/native_android/` | Native Android Compose App |
| `frontend/mobile/lib/` | `frontend/mobile/lib/` | Canonical Flutter Source |
| `frontend/mobile/web/` | `frontend/mobile/web/` | Canonical Flutter Web Runner |
| `frontend/mobile/test/` | `frontend/mobile/test/` | Canonical Flutter Tests |
| `frontend/mobile/assets/` | `frontend/mobile/assets/` | Canonical Flutter Assets |
| `frontend/mobile/pubspec.yaml` | `frontend/mobile/pubspec.yaml` | Canonical Flutter Config |
| `backend/main.py` | `backend/app/main.py` | FastAPI App Entrypoint |
| `backend/requirements.txt` | `backend/requirements.txt` | Python Dependencies |
| `database/schema/` | `database/schema/` | DB Schemas |
| `database/migrations/` | `database/migrations/` | DB Migrations |
| `database/seed/` | `database/seed/` | DB Seed Data |
| `docs/architecture/DESIGN.md` | `docs/architecture/DESIGN.md` | Architecture Documentation |
| `DESIGN.md` | `DESIGN.md` | Root Design Spec |
| `README.md` | `README.md` | Monorepo Root Overview |
| `firebase.json` | `firebase.json` | Firebase Configuration |
| `firestore.rules` | `firestore.rules` | Security Rules |
| `.firebaserc` | `.firebaserc` | Project Identifier |

---

## 5. Potential Conflicts & Import/Configuration Updates

1. **Backend Import Update**:
   - `backend/main.py` moving to `backend/app/main.py`.
   - Command to run backend: `python -m uvicorn app.main:app --reload` (from `backend/` directory).
2. **Flutter Web & Test Execution**:
   - Command to test: `flutter test` from `frontend/mobile/`.
   - Command to analyze: `flutter analyze` from `frontend/mobile/`.
   - Relative asset paths in `frontend/mobile/pubspec.yaml` (`assets/images/`) resolve within `frontend/mobile/assets/images/`.
3. **Native Android Gradle**:
   - Gradle wrapper and version catalogs are self-contained in `frontend/native_android/`.
   - Command to build: `.\gradlew.bat assembleDebug` from `frontend/native_android/`.
4. **Firebase Configuration**:
   - `firebase.json` and `firestore.rules` remain at root for centralized deployments via Firebase CLI.

---

## 6. Post-Approval Verification Checklist

- [ ] Execute `flutter pub get` in `frontend/mobile/`
- [ ] Execute `flutter analyze` in `frontend/mobile/`
- [ ] Execute `flutter test` in `frontend/mobile/`
- [ ] Execute `.\gradlew.bat tasks` in `frontend/native_android/`
- [ ] Execute `python -m compileall .` in `backend/`
- [ ] Verify backend import: `python -c "from app.main import app; print(app.title)"` in `backend/`
- [ ] Generate `docs/REORGANIZATION_REPORT.md`
