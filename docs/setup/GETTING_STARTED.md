# SevakConnect Setup & Developer Getting Started Guide

This guide walks you through setting up and running each subproject in the SevakConnect monorepo.

---

## 1. Prerequisites

- **Flutter SDK**: `>=3.2.0 <4.0.0`
- **Python**: `>=3.10`
- **Android Studio / JDK**: Java 17 or 21 (for Native Android development)
- **Firebase CLI**: `firebase-tools` (authenticated with access to `sevakconnect-2026`)

---

## 2. Running the Flutter App (`frontend/mobile/`)

```powershell
cd frontend/mobile

# 1. Install Flutter dependencies
flutter pub get

# 2. Run static analysis
flutter analyze

# 3. Run automated tests
flutter test

# 4. Run on Chrome (Web Dashboard)
flutter run -d chrome
```

---

## 3. Running the Native Android App (`frontend/android_native/`)

1. Open **Android Studio**.
2. Select **Open** and choose the `frontend/android_native` folder.
3. Allow Gradle to sync with the project.
4. Run on an Android Device or Emulator.

Alternatively via CLI:
```powershell
cd frontend/android_native
$env:JAVA_HOME="C:\Program Files\Android\Android Studio\jbr"
.\gradlew.bat assembleDebug
```

---

## 4. Running the FastAPI Backend (`backend/`)

```powershell
cd backend

# 1. Install dependencies
pip install -r requirements.txt

# 2. Run development server
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

- API Root: `http://127.0.0.1:8000/`
- Health Check: `http://127.0.0.1:8000/health`
- Interactive API Docs (Swagger): `http://127.0.0.1:8000/docs`

---

## 5. Firebase Security Rules & Deployment

From repository root:
```powershell
firebase deploy --only firestore:rules
```
