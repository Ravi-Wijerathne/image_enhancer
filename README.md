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
│   ├── requirements.txt         # Core Python dependencies
│   ├── requirements-test.txt    # Testing dependencies (pytest, httpx)
│   ├── tests/                   # Backend test suite (test_main, test_pipeline)
│   ├── models/                  # AI Model weights directory (git-ignored)
│   │   ├── realesrgan/          # Stores RealESRGAN_x4plus.pth
│   │   └── gfpgan/              # Stores GFPGANv1.4.pth
│   ├── gfpgan/weights/          # Stores Facexlib facial detection & parsing models
│   ├── input/                   # Temporary uploaded images directory (git-ignored)
│   └── output/                  # Processed enhanced images directory (git-ignored)
├── mobile/                      # Flutter application source code (Android, iOS, macOS)
│   └── lib/
│       └── services/
│           └── api_service.dart # API endpoint configuration
├── docs/                        # Architecture & system design documentation
└── .gitignore                   # Excludes heavy AI models, venv, build artifacts & cache
```

---

## Prerequisites & Python Compatibility

### 1. Python Version Guidance

| Python Version | Compatibility Status | Notes |
| :--- | :--- | :--- |
| **Python 3.9 – 3.12** | **Recommended (Most Stable)** | Has pre-built binary wheels on PyPI for all standard packages. |
| **Python 3.13 – 3.15+** | **Supported with Updated Config** | Requires NumPy 2.x and PyTorch nightly/CPU extra index URL (configured in `requirements.txt`). |

> [!NOTE]
> If you already have **Python 3.13, 3.14, or 3.15** installed on your system, **do not downgrade or uninstall it**. The codebase and `requirements.txt` have been adapted to run directly on newer Python versions.

### 2. General Requirements
- **pip**: Python package installer (upgrade to latest with `python -m pip install --upgrade pip`).
- **C++ Build Tools**: Required on Windows if packages need native compilation (MSVC Build Tools from Visual Studio installer) or `build-essential` on Linux / Xcode Tools on macOS.
- **Flutter SDK**: Stable channel (latest version) with Dart.

---

## AI Model Weights Setup

Heavy binary AI model weights (`*.pth`) are **excluded from Git tracking via `.gitignore`** due to file size limits. 

Before running inference, ensure the following model weight files are present in their target directories inside `backend/`:

| Model | Filename | Size | Target Directory | Direct Download Link |
| :--- | :--- | :--- | :--- | :--- |
| **Real-ESRGAN** | `RealESRGAN_x4plus.pth` | ~67 MB | `backend/models/realesrgan/` | [Download](https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth) |
| **GFPGAN v1.4** | `GFPGANv1.4.pth` | ~348 MB | `backend/models/gfpgan/` | [Download](https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.4.pth) |
| **Facexlib ResNet50** | `detection_Resnet50_Final.pth` | ~109 MB | `backend/gfpgan/weights/` | [Download](https://github.com/xinntao/facexlib/releases/download/v0.1.0/detection_Resnet50_Final.pth) |
| **Facexlib ParseNet** | `parsing_parsenet.pth` | ~85 MB | `backend/gfpgan/weights/` | [Download](https://github.com/xinntao/facexlib/releases/download/v0.2.2/parsing_parsenet.pth) |

### Quick Model Download Commands

Run the following commands from the repository root:

#### Windows (PowerShell):
```powershell
# 1. Create target directories
New-Item -ItemType Directory -Force -Path "backend/models/realesrgan", "backend/models/gfpgan", "backend/gfpgan/weights"

# 2. Download Real-ESRGAN weight (~67MB)
curl.exe -L "https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth" -o "backend/models/realesrgan/RealESRGAN_x4plus.pth"

# 3. Download GFPGAN v1.4 weight (~348MB)
curl.exe -L "https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.4.pth" -o "backend/models/gfpgan/GFPGANv1.4.pth"

# 4. Download Facexlib weights
curl.exe -L "https://github.com/xinntao/facexlib/releases/download/v0.1.0/detection_Resnet50_Final.pth" -o "backend/gfpgan/weights/detection_Resnet50_Final.pth"
curl.exe -L "https://github.com/xinntao/facexlib/releases/download/v0.2.2/parsing_parsenet.pth" -o "backend/gfpgan/weights/parsing_parsenet.pth"
```

#### macOS / Linux (Bash):
```bash
# 1. Create target directories
mkdir -p backend/models/realesrgan backend/models/gfpgan backend/gfpgan/weights

# 2. Download weights
curl -L https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth -o backend/models/realesrgan/RealESRGAN_x4plus.pth
curl -L https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.4.pth -o backend/models/gfpgan/GFPGANv1.4.pth
curl -L https://github.com/xinntao/facexlib/releases/download/v0.1.0/detection_Resnet50_Final.pth -o backend/gfpgan/weights/detection_Resnet50_Final.pth
curl -L https://github.com/xinntao/facexlib/releases/download/v0.2.2/parsing_parsenet.pth -o backend/gfpgan/weights/parsing_parsenet.pth
```

---

## Step-by-Step Setup & Launch Guide

### Step 1: Backend Setup (FastAPI)

1. **Navigate to the backend folder**:
   ```bash
   cd backend
   ```

2. **Create and activate a virtual environment**:
   - **Windows (PowerShell)**:
     ```powershell
     python -m venv venv
     .\venv\Scripts\Activate.ps1
     ```
     *(If PowerShell blocks activation scripts, run `Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned` first)*
   - **macOS / Linux**:
     ```bash
     python3 -m venv venv
     source venv/bin/activate
     ```

3. **Upgrade packaging tools**:
   ```bash
   pip install --upgrade pip setuptools wheel
   ```

4. **Install backend dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

5. **(Optional) Run tests to verify the installation**:
   ```bash
   pip install -r requirements-test.txt
   pytest
   ```
   *All 5 unit tests should pass.*

6. **Start the FastAPI backend server**:
   ```bash
   uvicorn main:app --reload
   ```
   - Server runs on: **`http://127.0.0.1:8000`**
   - Interactive Swagger API docs: **`http://127.0.0.1:8000/docs`**
   - Health check endpoint: **`http://127.0.0.1:8000/`** (returns `{"message": "AI Photo Enhancer Backend is running"}`)

---

### Step 2: Mobile App Setup (Flutter)

1. **Open a new terminal and navigate to the mobile folder**:
   ```bash
   cd mobile
   ```

2. **Fetch dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure API Base URL**:
   Open `mobile/lib/services/api_service.dart` (Line 8) and check `baseUrl`:
   ```dart
   static const String baseUrl = 'http://127.0.0.1:8000';
   ```
   - **Desktop (Windows/macOS) / Web**: Keep `http://127.0.0.1:8000`.
   - **Android Emulator**: Change to `http://10.0.2.2:8000` (Android routes `10.0.2.2` to host machine `127.0.0.1`).
   - **Physical Device**: Change to your host machine's local IP (e.g. `http://192.168.1.50:8000`).

4. **Run the Flutter app**:
   ```bash
   flutter run
   ```

---

## Common Setup Issues & Troubleshooting

This section covers common situations and errors encountered during first-time installation and their tested resolutions.

### 1. `ERROR: Could not find a version that satisfies the requirement torch`
- **Cause**: PyPI does not yet have stable wheels for newer Python releases (such as Python 3.14 or 3.15).
- **Solution**: Install PyTorch via its nightly/dev CPU repository by ensuring `requirements.txt` contains:
  ```txt
  --extra-index-url https://download.pytorch.org/whl/nightly/cpu
  --pre
  torch
  torchvision
  ```
  Or run manually:
  ```bash
  pip install --pre --extra-index-url https://download.pytorch.org/whl/nightly/cpu torch torchvision
  ```

---

### 2. `ERROR: Ignored the following versions that require a different python version: numpy 1.26.x`
- **Cause**: Older NumPy versions (`<3.13, >=3.9`) do not support Python 3.13+.
- **Solution**: Upgrade NumPy to version 2.x:
  ```bash
  pip install "numpy>=2.0.0"
  ```

---

### 3. `KeyError: '__version__'` during `basicsr` installation
- **Cause**: In Python 3.13+, PEP 667 modified how `exec(code, locals())` interacts with function namespaces in Python. Upstream `basicsr` 1.4.2's `setup.py` attempts to read its version using `exec()`, which throws `KeyError: '__version__'`.
- **Solution**: Install `basicsr` without build isolation from the Python 3.13+-compatible fork:
  ```bash
  pip install --no-deps --no-build-isolation git+https://github.com/Disty0/BasicSR.git
  ```

---

### 4. `Exception: Building py-lmdb from source on Windows requires the "patch-ng" python module` or MSVC Linker Error (`LNK1104`)
- **Cause**: `basicsr` and `gfpgan` list `lmdb` and `scikit-image` in their package metadata for training datasets. However, `lmdb` requires `patch-ng` and native compilation on Windows, which fails under MSVC. These libraries are **not** needed for inference.
- **Solution**: Install `patch-ng` first:
  ```bash
  pip install patch-ng
  ```
  Install `basicsr`, `gfpgan`, and `realesrgan` without pulling redundant training dependencies:
  ```bash
  pip install --no-deps realesrgan gfpgan facexlib
  ```

---

### 5. `FileNotFoundError: ... RealESRGAN_x4plus.pth`
- **Cause**: The server or processing pipeline cannot find the binary weights files in `backend/models/`.
- **Solution**: Download the weights using the commands in the [AI Model Weights Setup](#ai-model-weights-setup) section. Check that:
  - `backend/models/realesrgan/RealESRGAN_x4plus.pth` exists.
  - `backend/models/gfpgan/GFPGANv1.4.pth` exists.
  *(Note: The server will still boot even if weights are missing, but requests to `/enhance` will notify you that weights must be downloaded).*

---

### 6. `ImportError: cannot import name 'AsyncClient' from 'httpx'` when running `pytest`
- **Cause**: Some pre-release development builds of `httpx` (1.0.dev) altered the top-level exports.
- **Solution**: Pin `httpx` to stable version `<1.0`:
  ```bash
  pip install "httpx<1.0,>=0.27.0"
  ```

---

### 7. Flutter App Displays: `Failed to enhance image. Please check if backend is running on 127.0.0.1:8000`
- **Cause**: Network host unreachable or backend is not active.
- **Solution**:
  1. Verify the backend is running by opening `http://127.0.0.1:8000` in your web browser. You should see:
     ```json
     {"message": "AI Photo Enhancer Backend is running"}
     ```
  2. If using an **Android Emulator**, edit `mobile/lib/services/api_service.dart` and set `baseUrl` to `http://10.0.2.2:8000`.
  3. Ensure your local firewall allows inbound connections on port 8000.

---

## Verification & API Endpoints

Once the FastAPI backend is running, verify the following endpoints:

| Method | Endpoint | Description | Expected Output |
| :--- | :--- | :--- | :--- |
| `GET` | `/` | Backend Health Check | `{"message": "AI Photo Enhancer Backend is running"}` |
| `GET` | `/docs` | Swagger Interactive UI | Full API explorer and interactive test client |
| `POST` | `/enhance` | Image Processing | Takes `multipart/form-data` with `image` file, returns enhanced JPEG |

---

## Performance Optimization Notes

- **Tiled Processing (`tile=400`)**: `pipeline.py` divides large images into tiles to keep RAM and VRAM usage low, preventing memory crashes on laptops.
- **Automatic Downscaling**: Input images with any dimension larger than 1024px are downscaled proportionally prior to enhancement for faster processing.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
