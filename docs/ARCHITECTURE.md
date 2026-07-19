# 🏗️ AI Photo Enhancer - ARCHITECTURE

## 📌 Overview

This is a **local-first architecture**:

[ Flutter App ]
        ↓
[ Local FastAPI Server ]
        ↓
[ AI Processing Pipeline ]
        ↓
[ Local File System ]

---

## 📱 Flutter App

### Responsibilities:
- Select image
- Send HTTP request
- Show loading state
- Display enhanced image

### Key Modules:
- UI (screens/widgets)
- API service
- Image handling

---

## 🔌 Backend (FastAPI)

### Responsibilities:
- Receive image
- Trigger AI pipeline
- Return processed image

### Endpoints:

POST /enhance
- Input: image file
- Output: enhanced image

---

## 🧠 AI Pipeline

### Flow:

1. Load image
2. Resize (optimize)
3. Real-ESRGAN (upscale + denoise)
4. GFPGAN (face enhancement)
5. OpenCV (color tuning)
6. Save output

---

## 📂 Folder Structure

### Backend

backend/
│
├── main.py
├── pipeline.py
├── models/
│   ├── realesrgan/
│   ├── gfpgan/
│
├── input/
├── output/

---

### Flutter

mobile/
│
├── lib/
│   ├── screens/
│   ├── widgets/
│   ├── services/
│
├── assets/

---

## 🔄 Data Flow

1. User selects image
2. App sends POST request
3. Backend processes image
4. Backend returns result
5. App displays output

---

## ⚡ Performance Notes

- Resize large images before processing
- Use async API calls
- Avoid blocking UI