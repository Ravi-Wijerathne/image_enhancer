# AI Image Enhancer

An AI-powered application for image enhancement. It consists of a Flutter-based mobile frontend and a FastAPI-based backend that orchestrates state-of-the-art AI models for tasks like super-resolution, face restoration, and noise reduction.

## Project Architecture

This repository uses a mono-repo structure containing both the mobile application and the backend API.

- `mobile/`: The Flutter front-end application (Android & iOS).
- `backend/`: The Python FastAPI application serving AI models (Real-ESRGAN, GFPGAN, OpenCV, etc.).
- `docs/`: System architecture and additional documentation.

## Prerequisites

To run this project, ensure you have the following installed on your local machine:

**For Mobile (Flutter):**
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)
- Dart SDK (comes with Flutter)
- Android Studio / Xcode (for emulation/builds)
- Physical device or emulator

**For Backend (FastAPI):**
- [Python](https://www.python.org/downloads/) (3.9 to 3.11 recommended)
- `pip` (Python package manager)
- (Optional, but recommended) CUDA-enabled GPU for faster image processing.

---

## Backend Setup Instructions

The backend acts as an API server providing endpoints to process and enhance images.

1. **Navigate to the backend directory:**
   ```bash
   cd backend
   ```

2. **Create a virtual environment:**
   ```bash
   python -m venv venv
   ```

3. **Activate the virtual environment:**
   - **macOS/Linux:**
     ```bash
     source venv/bin/activate
     ```
   - **Windows:**
     ```bash
     venv\Scripts\activate
     ```

4. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```
   *(Note: if `requirements.txt` does not exist yet, you may need to install frameworks directly: `pip install fastapi uvicorn python-multipart pydantic` plus the relevant AI frameworks like `opencv-python`)*

5. **Start the FastAPI development server:**
   ```bash
   uvicorn main:app --reload
   ```
   By default, this will run at `http://127.0.0.1:8000`. You can test the API by navigating to `http://127.0.0.1:8000/docs` to view the Swagger UI.

---

## Mobile Setup Instructions

The mobile application allows users to select images, upload them to the backend, and view the enhanced results.

1. **Navigate to the mobile directory:**
   ```bash
   cd mobile
   ```

2. **Fetch Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API URL (if necessary):**
   By default, the mobile app needs to know where the backend is hosted. If testing on a physical device, ensure the mobile app points to your local machine's IP address instead of `localhost` or `127.0.0.1` (e.g., `192.168.1.x:8000`). For Android emulators, `10.0.2.2:8000` is mapped to the host's localhost.

4. **Run the Flutter application:**
   ```bash
   flutter run
   ```
   Choose the appropriate device (iOS simulator, Android emulator, or web/macOS desktop) when prompted.

---

## Additional Information

- **Branching Strategy:** Please create separate branches for features, bug fixes, or chores (e.g., `feature/login`, `bugfix/upload-error`).
- **Contributing:** Before making any commits, make sure your code is well-formatted and passes standard lints (use `flutter analyze` for the mobile codebase and `flake8` or `black` for the Python codebase).

## License

This project is licensed under the MIT License.
