import os
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
import shutil
from pathlib import Path
from pipeline import process_image

app = FastAPI(title="AI Photo Enhancer API")

# Allow CORS for Flutter mobile/web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

INPUT_DIR = Path("input")
OUTPUT_DIR = Path("output")

# Ensure directories exist
INPUT_DIR.mkdir(parents=True, exist_ok=True)
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

@app.get("/")
def read_root():
    return {"message": "AI Photo Enhancer Backend is running"}

@app.post("/enhance")
async def enhance_image(image: UploadFile = File(...)):
    if not image.filename:
        raise HTTPException(status_code=400, detail="No file uploaded")
    
    # Save the uploaded file
    input_path = INPUT_DIR / image.filename
    try:
        with open(input_path, "wb") as buffer:
            shutil.copyfileobj(image.file, buffer)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to save image: {e}")
    finally:
        image.file.close()
        
    # Process the image
    try:
        output_path = process_image(input_path, OUTPUT_DIR)
        
        # Return the processed image
        return FileResponse(
            path=output_path, 
            media_type="image/jpeg", 
            filename=f"enhanced_{image.filename}"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to process image: {e}")
