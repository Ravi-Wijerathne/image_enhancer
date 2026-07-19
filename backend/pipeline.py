import cv2
import numpy as np
from pathlib import Path

def process_image(input_path: Path, output_dir: Path) -> Path:
    """
    Processes an image. Currently uses OpenCV for basic enhancement 
    as a placeholder for heavy AI models (Real-ESRGAN/GFPGAN).
    """
    # Load image
    img = cv2.imread(str(input_path))
    if img is None:
        raise ValueError("Could not read the uploaded image.")

    # 1. Resize (optimize for processing if too large)
    # E.g., max width/height of 1024 to speed up
    max_dim = 1024
    h, w = img.shape[:2]
    if max(h, w) > max_dim:
        scale = max_dim / max(h, w)
        img = cv2.resize(img, (int(w * scale), int(h * scale)), interpolation=cv2.INTER_AREA)

    # 2. Placeholder AI: OpenCV Denoise
    # Simulating Real-ESRGAN (upscale + denoise)
    denoised = cv2.fastNlMeansDenoisingColored(img, None, 10, 10, 7, 21)

    # 3. Placeholder AI: OpenCV Color Tuning / Sharpening
    # Simulating GFPGAN/OpenCV color tuning
    # Create a sharpening kernel
    kernel = np.array([[-1,-1,-1], 
                       [-1, 9,-1],
                       [-1,-1,-1]])
    sharpened = cv2.filter2D(denoised, -1, kernel)

    # 4. Save output
    # Always save as high-quality JPEG
    output_filename = f"enhanced_{input_path.stem}.jpg"
    output_path = output_dir / output_filename
    
    cv2.imwrite(str(output_path), sharpened, [int(cv2.IMWRITE_JPEG_QUALITY), 95])
    
    return output_path
