import io

import pytest

from app.app import app


@pytest.fixture
def client():
    app.config["TESTING"] = True

    with app.test_client() as client:
        yield client


def test_home_page(client):
    response = client.get("/")

    assert response.status_code == 200
    assert b"ImageForge" in response.data


def test_health_endpoint(client):
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json["status"] == "healthy"
    assert response.json["service"] == "imageforge"


def test_upload_without_file(client):
    response = client.post("/upload")

    assert response.status_code == 400
    assert response.json["error"] == "No file provided"


def test_upload_without_bucket(client, monkeypatch):
    monkeypatch.delenv("S3_BUCKET", raising=False)

    response = client.post(
        "/upload",
        data={},
        content_type="multipart/form-data"
    )

    assert response.status_code == 400
    assert response.json["error"] == "No file provided"


def test_upload_invalid_extension(client, monkeypatch):
    monkeypatch.setenv("S3_BUCKET", "test-bucket")

    response = client.post(
        "/upload",
        data={
            "file": (
                io.BytesIO(b"this is not an image"),
                "test.txt"
            )
        },
        content_type="multipart/form-data"
    )

    assert response.status_code == 400
    assert "Only JPG" in response.json["error"]