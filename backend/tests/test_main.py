import pytest
from httpx import AsyncClient, ASGITransport
from pathlib import Path
from main import app, INPUT_DIR, OUTPUT_DIR
import os

@pytest.fixture
def client():
    # Use ASGITransport for testing FastAPI app asynchronously
    transport = ASGITransport(app=app)
    return AsyncClient(transport=transport, base_url="http://test")

@pytest.mark.asyncio
async def test_read_root(client: AsyncClient):
    response = await client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "AI Photo Enhancer Backend is running"}

@pytest.mark.asyncio
async def test_enhance_image_no_file(client: AsyncClient):
    response = await client.post("/enhance")
    assert response.status_code == 422 # Unprocessable entity because missing 'image' field

@pytest.mark.asyncio
async def test_enhance_image_success(client: AsyncClient, mocker, dummy_image_path: Path):
    # Mock the process_image function so we don't run ML models
    def mock_process_image(input_path: Path, output_dir: Path) -> Path:
        output_path = output_dir / f"enhanced_{input_path.name}"
        # Just copy the dummy image to simulate processing
        import shutil
        shutil.copy(input_path, output_path)
        return output_path

    mocker.patch("main.process_image", side_effect=mock_process_image)

    # Clean up input/output before test
    dummy_input_path = INPUT_DIR / dummy_image_path.name
    dummy_output_path = OUTPUT_DIR / f"enhanced_{dummy_image_path.name}"
    if dummy_input_path.exists(): dummy_input_path.unlink()
    if dummy_output_path.exists(): dummy_output_path.unlink()

    # Read dummy image content
    file_content = dummy_image_path.read_bytes()
    files = {"image": (dummy_image_path.name, file_content, "image/jpeg")}

    response = await client.post("/enhance", files=files)
    
    assert response.status_code == 200
    assert response.headers["content-type"] == "image/jpeg"
    assert len(response.content) > 0

    # Clean up after test
    if dummy_input_path.exists(): dummy_input_path.unlink()
    if dummy_output_path.exists(): dummy_output_path.unlink()
