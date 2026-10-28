# StudyFlow

**StudyFlow** is a Flutter study-management application built as a final course project. It helps students manage subjects, tasks, and exams through a simple Arabic RTL interface connected to a PHP/MySQL REST API.

## Main Features

- Arabic RTL user interface
- Dashboard with study progress and live statistics
- Subjects management: Create, Read, Update, Delete
- Tasks management: Create, Read, Update, Delete
- Task search, status filtering, and priority filtering
- Exams and progress tracking: Create, Read, Update, Delete
- Automatic score percentage and average calculation
- PHP REST API with MySQL database
- Provider + ChangeNotifier state management
- Repository layer separating UI state from API access
- Foreign-key cascade deletion for related tasks and exams
- API validation and JSON error responses

## Project Architecture

```text
Flutter UI
   ↓
Provider / ChangeNotifier
   ↓
Repository Layer
   ↓
ApiService (HTTP/JSON)
   ↓
PHP REST API
   ↓
MySQL
```

## Screens

1. **الرئيسية** — statistics, progress, priorities, upcoming exams
2. **المواد الدراسية** — subject CRUD and search
3. **المهام** — task CRUD, search, status and priority filters
4. **الاختبارات والتقدم** — exam CRUD, scores, average and progress

## Technologies

- Flutter / Dart
- Provider
- HTTP REST API
- PHP 8+
- MySQL / MariaDB
- XAMPP

## Quick Start

### Backend

1. Copy `studyflow_api` into XAMPP `htdocs`.
2. Start Apache and MySQL.
3. Open phpMyAdmin and import `studyflow_api/database.sql`.
4. Verify the API in a browser:
   `http://localhost/studyflow_api/subjects`

### Flutter

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2/studyflow_api
```

For a physical Android phone connected to the same Wi-Fi as the PC, replace `10.0.2.2` with the PC's local IPv4 address, for example:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10/studyflow_api
```

See `SETUP.md` for the complete setup and troubleshooting steps.

## Academic Requirements Covered

- Four main screens for a solo project
- Provider with `ChangeNotifier` and `notifyListeners()`
- SQL database integration
- REST API integration
- CRUD operations for the main entities
- Separation between UI, state management, repositories, API service, and backend
