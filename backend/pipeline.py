import cv2
import numpy as np
from pathlib import Path
import warnings

# Suppress warnings from PyTorch/BasicSR
warnings.filterwarnings('ignore')

import torchvision
try:
    import torchvision.transforms.functional_tensor
except ImportError:
    import torchvision.transforms.functional as functional_tensor
    import sys
    sys.modules['torchvision.transforms.functional_tensor'] = functional_tensor

from basicsr.archs.rrdbnet_arch import RRDBNet
from realesrgan import RealESRGANer
from gfpgan import GFPGANer

backend_dir = Path(__file__).parent.resolve()
realesrgan_model_path = backend_dir / "models" / "realesrgan" / "RealESRGAN_x4plus.pth"
gfpgan_model_path = backend_dir / "models" / "gfpgan" / "GFPGANv1.4.pth"

# Initialize models once when the module loads
try:
    rrdb_model = RRDBNet(num_in_ch=3, num_out_ch=3, num_feat=64, num_block=23, num_grow_ch=32, scale=4)

    upsampler = RealESRGANer(
        scale=4,
        model_path=str(realesrgan_model_path),
        model=rrdb_model,
        tile=400,    # tile size for memory management (helps on laptops)
        tile_pad=10,
        pre_pad=0,
        half=False   # Keep false for better CPU/MPS compatibility
    )

    face_enhancer = GFPGANer(
        model_path=str(gfpgan_model_path),
        upscale=2,
        arch='clean',
        channel_multiplier=2,
        bg_upsampler=upsampler
    )
except Exception:
    # When weights are not yet downloaded (e.g. during testing or initial setup)
    class _FallbackEnhancer:
        def enhance(self, img, *args, **kwargs):
            raise RuntimeError(
                f"Model weights not found. Please ensure Real-ESRGAN and GFPGAN models are downloaded to {backend_dir / 'models'}."
            )
    rrdb_model = None
    upsampler = None
    face_enhancer = _FallbackEnhancer()

def process_image(input_path: Path, output_dir: Path) -> Path:
    """
    Processes an image using Real-ESRGAN for background upscaling 
    and GFPGAN for face restoration.
    """
    # Load image
    img = cv2.imread(str(input_path))
    if img is None:
        raise ValueError("Could not read the uploaded image.")

    # Resize very large images to prevent out-of-memory errors on local machines
    max_dim = 1024
    h, w = img.shape[:2]
    if max(h, w) > max_dim:
        scale = max_dim / max(h, w)
        img = cv2.resize(img, (int(w * scale), int(h * scale)), interpolation=cv2.INTER_AREA)

    # Process with GFPGAN (which uses RealESRGAN for the background)
    _, _, output_img = face_enhancer.enhance(
        img, 
        has_aligned=False, 
        only_center_face=False, 
        paste_back=True
    )

    # Save output
    output_filename = f"enhanced_{input_path.stem}.jpg"
    output_path = output_dir / output_filename
    cv2.imwrite(str(output_path), output_img, [int(cv2.IMWRITE_JPEG_QUALITY), 95])
    
    return output_path
