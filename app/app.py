from flask import Flask, jsonify, render_template, request
import boto3
import os
import uuid
from botocore.exceptions import ClientError

app = Flask(__name__)

AWS_REGION = os.getenv("AWS_REGION", "us-east-1")

s3 = boto3.client("s3", region_name=AWS_REGION)

ALLOWED_EXTENSIONS = {
    ".jpg",
    ".jpeg",
    ".png",
    ".gif",
    ".webp"
}


def get_bucket():
    return os.getenv("S3_BUCKET")


@app.route("/")
def home():
    return render_template("index.html")


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "service": "imageforge"
    }), 200


@app.route("/upload", methods=["POST"])
def upload():
    if "file" not in request.files:
        return jsonify({
            "error": "No file provided"
        }), 400

    file = request.files["file"]

    if not file.filename:
        return jsonify({
            "error": "No file selected"
        }), 400

    bucket = get_bucket()

    if not bucket:
        return jsonify({
            "error": "S3_BUCKET environment variable is not configured"
        }), 500

    original_name = file.filename
    extension = os.path.splitext(original_name)[1].lower()

    if extension not in ALLOWED_EXTENSIONS:
        return jsonify({
            "error": "Only JPG, JPEG, PNG, GIF and WEBP images are allowed"
        }), 400

    object_key = f"images/{uuid.uuid4()}{extension}"

    try:
        s3.upload_fileobj(
            file,
            bucket,
            object_key,
            ExtraArgs={
                "ContentType": file.content_type or "application/octet-stream"
            }
        )

        return jsonify({
            "message": "Image uploaded successfully",
            "filename": original_name,
            "object_key": object_key,
            "bucket": bucket
        }), 201

    except ClientError:
        return jsonify({
            "error": "Failed to upload image"
        }), 500


@app.route("/images", methods=["GET"])
def list_images():
    bucket = get_bucket()

    if not bucket:
        return jsonify({
            "error": "S3_BUCKET environment variable is not configured"
        }), 500

    try:
        response = s3.list_objects_v2(
            Bucket=bucket,
            Prefix="images/"
        )

        objects = response.get("Contents", [])

        images = [
            {
                "key": obj["Key"],
                "size": obj["Size"],
                "last_modified": obj["LastModified"].isoformat()
            }
            for obj in objects
        ]

        return jsonify({
            "count": len(images),
            "images": images
        }), 200

    except ClientError:
        return jsonify({
            "error": "Failed to list images"
        }), 500


@app.route("/images/<path:object_key>", methods=["DELETE"])
def delete_image(object_key):
    bucket = get_bucket()

    if not bucket:
        return jsonify({
            "error": "S3_BUCKET environment variable is not configured"
        }), 500

    if not object_key.startswith("images/"):
        object_key = f"images/{object_key}"

    try:
        s3.delete_object(
            Bucket=bucket,
            Key=object_key
        )

        return jsonify({
            "message": "Image deleted successfully",
            "object_key": object_key
        }), 200

    except ClientError:
        return jsonify({
            "error": "Failed to delete image"
        }), 500


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000,
        debug=False
    )