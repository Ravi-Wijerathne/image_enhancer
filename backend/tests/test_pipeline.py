import pytest
from pathlib import Path
import cv2
import numpy as np

# We mock the entire pipeline module's heavy ML dependencies before importing it
@pytest.fixture(autouse=True)
def mock_ml_models(mocker):
    # Mock GFPGANer and RealESRGANer classes
    mocker.patch("pipeline.GFPGANer")
    mocker.patch("pipeline.RealESRGANer")
    mocker.patch("pipeline.RRDBNet")

def test_process_image_success(mocker, dummy_image_path: Path, tmp_path: Path):
    # We must import pipeline inside the test after mocking has occurred,
    # or reload the module if necessary. To be safe, we mock at the module level.
    import pipeline
    
    # Mock face_enhancer.enhance to return a dummy enhanced image
    dummy_enhanced = np.zeros((20, 20, 3), dtype=np.uint8)
    dummy_enhanced[8:12, 8:12] = 255
    
    # The enhance method returns (faces, cropped_faces, restored_img)
    mocker.patch.object(pipeline.face_enhancer, "enhance", return_value=(None, None, dummy_enhanced))

    output_dir = tmp_path / "output"
    output_dir.mkdir()

    output_path = pipeline.process_image(dummy_image_path, output_dir)

    assert output_path.exists()
    assert output_path.parent == output_dir
    assert output_path.name == f"enhanced_{dummy_image_path.stem}.jpg"
    
    # Verify it actually wrote an image by reading it back
    saved_img = cv2.imread(str(output_path))
    assert saved_img is not None
    assert saved_img.shape == (20, 20, 3)

def test_process_image_invalid_input(tmp_path: Path):
    import pipeline
    
    invalid_path = tmp_path / "nonexistent.jpg"
    output_dir = tmp_path / "output"
    
    with pytest.raises(ValueError, match="Could not read the uploaded image"):
        pipeline.process_image(invalid_path, output_dir)
