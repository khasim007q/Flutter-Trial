# Task Management Flutter Assignment

This project is a full-stack Task Management application built for a technical assignment. It implements the "Full-Stack Builder" track requirements, utilizing a modern Flutter frontend connected to a Python FastAPI backend with a SQLite database.

## Architecture Overview

### The Full-Stack Builder (6-8 hours estimated)
- **Frontend**: Built with Flutter & Dart. Implements a highly responsive Material 3 UI with a custom design system, squircle iOS-style corners, dynamic state management via the `provider` package, and comprehensive input validation.
- **Backend**: Built with Python using FastAPI. Provides a blazing-fast, strongly-typed RESTful API.
- **Database**: SQLite, utilizing SQLAlchemy as the ORM for robust data persistence and querying.

### API Connection
The Flutter app connects to the Python REST API via standard HTTP requests.
- The `ApiService` manages all network calls and encapsulates serialization & error handling.
- By default, the app is configured to connect to `http://10.0.2.2:8000` which maps to the host's localhost on Android Emulators. This can be configured in `lib/services/api_service.dart`.

## Core Features
1. **Full CRUD Operations**: Create, Read, Update, and Delete tasks.
2. **Task Dependencies (Blocked By)**: Tasks can be blocked by other tasks. Blocked tasks appear with a lock icon and reduced opacity until their blocker is marked as "Done".
3. **Advanced Filtering & Search**: Real-time search by task title or description, and rapid state filtering (All, To-Do, In Progress, Done).

### Recurring Tasks Logic
A core requirement for this project was to handle recurring tasks natively. 
- The task creation screen includes a **"Recurring Task"** toggle, allowing users to select a recurrence interval (e.g., *Daily* or *Weekly*).
- **Backend Automation**: When a recurring task is updated and marked as "Done", the Python API automatically kicks off a duplicate generation routine. It creates an exact copy of the task, resets its status to "To-Do", and pushes the Due Date forward by 1 day (Daily) or 7 days (Weekly). The original task remains logged as completed.

---

## Step-by-Step Setup Instructions

### Prerequisites
- **Python 3.10+**
- **Flutter SDK** (Version 3.10 or newer)
- An Android/iOS Emulator or physical device

### 1. Running the Backend (FastAPI)

Open your terminal and navigate to the `backend` directory:

```bash
cd backend
```

*(Optional but recommended) Create and activate a virtual environment:*
```bash
python -m venv venv
# On Windows: venv\Scripts\activate
# On macOS/Linux: source venv/bin/activate
```

Install the required Python dependencies:
```bash
pip install -r requirements.txt
```

Start the FastAPI server:
```bash
uvicorn main:app --reload --port 8000
```
*The backend is now actively running on `http://127.0.0.1:8000`.*
*You can view the interactive API documentation at `http://127.0.0.1:8000/docs`.*

### 2. Running the Frontend (Flutter)

Open a new terminal window and navigate to the `task_manager` directory:

```bash
cd task_manager
```

Fetch all Flutter packages:
```bash
flutter pub get
```

Launch the application:
```bash
flutter run
```
*Note: If you are running the app on a physical device or an iOS simulator instead of an Android Emulator, you must update the `baseUrl` in `lib/services/api_service.dart` from `http://10.0.2.2:8000` to your local machine's IP address (e.g., `http://192.168.1.X:8000`).*

---

## AI Usage Report

In the development of this project, an AI coding assistant was utilized to expedite the development cycle, ensure best practices, and architect a robust foundation. Below is a summary of the AI's contributions:

- **Architectural Planning**: Designed the full-stack architecture, including the SQLite-backed FastAPI endpoints, Pydantic schemas, and the Flutter state management pipeline using the `provider` state container.
- **Rapid Prototyping (CRUD & UI)**: Created boilerplate code for the REST endpoints and Dart data models containing comprehensive `fromJson` / `toJson` deserialization mappings. 
- **Design System Integration**: Enforced a premium, modern design aesthetic globally. Mapped custom color tokens to Material 3's `ColorScheme`, overrode default text styling to utilize `GoogleFonts.inter`, and successfully implemented smooth iOS-style "squircle" corners utilizing third-party rendering packages.
- **Complex Logic Implementation**: Wrote the robust backend logic for the "Blocked By" dependency feature and cleanly engineered the **Recurring Task** generation logic natively within the FastAPI database commit lifecycle.
- **Debugging & Polish**: Diagnosed and rectified subtle UI bugs including Material 3 FilterChip background gradient bleeding, state-preservation on task drafts, and solved Dart compiler warnings to guarantee a `flutter analyze` codebase passing perfectly.

### Developer (Human) Contributions
While the AI served as a rapid prototyping and implementation engine, the core product direction, environment setup, and critical reviews were conducted by the human developer:
- **Project Requirements & Scope**: Defined the rigorous feature set, recurring task specifications, and the full-stack boundaries for the system.
- **Design System & UX Stewardship**: Curated the custom palette, specified the usage of `Inter` typography, mandated the exact "squircle" iOS UI behavior, and enforced strict aesthetic guidelines on UI components (e.g., removing native Material shadows/gradients from chips for a flatter, modern look).
- **Environment & Execution**: Orchestrated the Python/Flutter execution environments, managed the dependencies lifecycle, and executed all compilation directives.
- **Quality Assurance**: Directed edge-case testing, manually verified the Flutter text-wrapping constraints, debugged complex UI artifact issues that emerged from third-party libraries, and guided the AI through iterative refinements to achieve the final polished output.

*All code generated by AI was thoroughly tested, iterated upon, and verified by the developer to ensure structural robustness and an intuitive user experience.*
