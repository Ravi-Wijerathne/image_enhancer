import pytest
from pathlib import Path
import numpy as np
import cv2

@pytest.fixture
def dummy_image_path(tmp_path: Path):
    """Creates a small dummy image for testing."""
    img_path = tmp_path / "dummy.jpg"
    # Create a 10x10 black square with a white dot in the middle
    img = np.zeros((10, 10, 3), dtype=np.uint8)
    img[4:6, 4:6] = 255
    cv2.imwrite(str(img_path), img)
    return img_path
