# AI Photo & Image Enhancer

An AI-powered, local-first image enhancement application. It combines a **Flutter** mobile frontend with a **FastAPI** backend that orchestrates state-of-the-art deep learning models for image upscaling, facial restoration, and quality enhancement.

---

## Key Features & AI Models

- **Background & General Image Upscaling**: Uses **Real-ESRGAN** (`RealESRGAN_x4plus.pth`, ~67MB) for 4x resolution upscaling and artifact reduction.
- **Facial Restoration & Enhancement**: Uses **GFPGAN v1.4** (`GFPGANv1.4.pth`, ~348MB) for sharpening, restoring, and detail-enhancing faces in degraded photos.
- **Facial Detection & Parsing**: Integrated with **Facexlib** weights (`detection_Resnet50_Final.pth` & `parsing_parsenet.pth`) for accurate face localization.
- **Memory-Efficient Tiled Inference**: Tiled processing (`tile=400`) and dimension scaling prevent Out-Of-Memory (OOM) errors on consumer laptops, CPUs, and Apple Silicon (MPS).
- **Privacy & Local-First Architecture**: All processing happens locally on your machine without relying on external cloud APIs.

---

## Repository Architecture

```text
.
├── backend/
│   ├── main.py                  # FastAPI server & endpoints (/enhance)
│   ├── pipeline.py              # AI model pipeline (Real-ESRGAN + GFPGAN)
│   ├── requirements.txt         # Python dependencies
│   ├── models/                  # AI Model weights directory (git-ignored)
│   │   ├── realesrgan/          # Stores RealESRGAN_x4plus.pth
│   │   └── gfpgan/              # Stores GFPGANv1.4.pth
│   ├── gfpgan/weights/          # Stores Facexlib facial detection & parsing models
│   ├── input/                   # Temporary uploaded images directory (git-ignored)
│   └── output/                  # Processed enhanced images directory (git-ignored)
├── mobile/                      # Flutter application source code (Android, iOS, macOS)
├── docs/                        # Architecture & system design documentation
└── .gitignore                   # Excludes heavy AI models, venv, build artifacts & cache
```

---

## Prerequisites

### For Backend (FastAPI & AI Models)
- **Python**: 3.9 – 3.11 recommended (compatible with 3.14)
- **pip**: Python package installer
- **C++ Build Tools**: Required for compiling native dependencies like `BasicSR` (e.g., Xcode Command Line Tools on macOS, MSVC Build Tools on Windows, or `build-essential` on Linux).
- **GPU Acceleration (Optional)**: CUDA-enabled NVIDIA GPU or Apple Silicon (MPS) for faster processing.

### For Mobile (Flutter App)
- **Flutter SDK**: Stable channel (latest version)
- **Dart SDK**: Included with Flutter
- **Android Studio / Xcode**: For running emulators or building native binaries
- Target device (Android/iOS emulator, macOS desktop, or physical phone)

---

## AI Model Weights Setup

Due to GitHub size limits, heavy binary AI model weights (`*.pth`) are **excluded from Git tracking via `.gitignore`**. 

Ensure the following model weight files are present in their corresponding paths inside `backend/` before starting the server:

| Model | Filename | Size | Target Path | Download Link |
| :--- | :--- | :--- | :--- | :--- |
| **Real-ESRGAN** | `RealESRGAN_x4plus.pth` | ~67 MB | `backend/models/realesrgan/` | [Download](https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth) |
| **GFPGAN v1.4** | `GFPGANv1.4.pth` | ~348 MB | `backend/models/gfpgan/` | [Download](https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.4.pth) |
| **Facexlib ResNet50** | `detection_Resnet50_Final.pth` | ~109 MB | `backend/gfpgan/weights/` | [Download](https://github.com/xinntao/facexlib/releases/download/v0.1.0/detection_Resnet50_Final.pth) |
| **Facexlib ParseNet** | `parsing_parsenet.pth` | ~85 MB | `backend/gfpgan/weights/` | [Download](https://github.com/xinntao/facexlib/releases/download/v0.2.2/parsing_parsenet.pth) |

### Quick Model Download Script (Terminal Commands)

From the project root, you can create the target folders and download all required models:

```bash
# Create model directories
mkdir -p backend/models/realesrgan backend/models/gfpgan backend/gfpgan/weights

# Download Real-ESRGAN weight
curl -L https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth \
  -o backend/models/realesrgan/RealESRGAN_x4plus.pth

# Download GFPGAN v1.4 weight
curl -L https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.4.pth \
  -o backend/models/gfpgan/GFPGANv1.4.pth

# Download Facexlib weights
curl -L https://github.com/xinntao/facexlib/releases/download/v0.1.0/detection_Resnet50_Final.pth \
  -o backend/gfpgan/weights/detection_Resnet50_Final.pth

curl -L https://github.com/xinntao/facexlib/releases/download/v0.2.2/parsing_parsenet.pth \
  -o backend/gfpgan/weights/parsing_parsenet.pth
```

---

## Environment Setup & Launch Instructions

### 1. Backend Setup (FastAPI)

1. **Navigate to the backend directory**:
   ```bash
   cd backend
   ```

2. **Create and activate a Python Virtual Environment**:
   - **macOS / Linux**:
     ```bash
     python3 -m venv venv
     source venv/bin/activate
     ```
   - **Windows**:
     ```bash
     python -m venv venv
     venv\Scripts\activate
     ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Verify Model Weights placement**:
   Ensure `backend/models/realesrgan/RealESRGAN_x4plus.pth` and `backend/models/gfpgan/GFPGANv1.4.pth` exist as described above.

5. **Start the FastAPI server**:
   ```bash
   uvicorn main:app --reload
   ```
   - The API will start on **`http://127.0.0.1:8000`**.
   - Interactive Swagger API documentation: **`http://127.0.0.1:8000/docs`**.

---

### 2. Mobile App Setup (Flutter)

1. **Navigate to the mobile directory**:
   ```bash
   cd mobile
   ```

2. **Install Flutter packages**:
   ```bash
   flutter pub get
   ```

3. **Configure API Endpoint Host**:
   - **Desktop (macOS/Windows) / Web**: Uses `http://127.0.0.1:8000`.
   - **Android Emulator**: Set base URL to `http://10.0.2.2:8000`.
   - **Physical Device**: Set base URL to your computer's local IP address (e.g., `http://192.168.1.X:8000`).

4. **Run the Flutter application**:
   ```bash
   flutter run
   ```
   Select your connected device or emulator when prompted.

---

## Performance Optimization Notes

- **Tiled Processing (`tile=400`)**: `pipeline.py` breaks images into tiles during processing to avoid high VRAM/RAM consumption.
- **Auto Image Downscaling**: Input images exceeding 1024px along their largest dimension are proportionally downscaled prior to AI enhancement to ensure fast response times on consumer hardware.

---

## License & Contributing

- **License**: MIT License
- **Contributing**: Please follow feature branch workflow (`feature/model-tuning`, `bugfix/api-connection`) and format code before submitting PRs (`flutter format .` and `black .`).
