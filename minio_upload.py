from minio import Minio
import argparse
import os

def upload(host, access_key, secret_key, bucket_name, destination_file, source_file):
    try:
        client = Minio(host, access_key, secret_key, secure=False)
        client.fput_object(bucket_name, destination_file, source_file)
        print(f"{source_file} successfully uploaded as object {destination_file} to bucket {bucket_name}")
    except Exception as e:
        print(f"Error while uploading object in MinIO -- {e}")

if __name__ == "__main__":
    # Get values from environment variables
    endpoint = os.getenv("MINIO_ENDPOINT")
    access_key = os.getenv("MINIO_ACCESS_KEY")
    secret_key = os.getenv("MINIO_SECRET_KEY")
    bucket_name = os.getenv("MINIO_BUCKET")
    destination_file = os.getenv("MINIO_DEST_PATH")
    source_file = os.getenv("MINIO_SOURCE_PATH")

    # Check if required values are set
    if not all([endpoint, access_key, secret_key, bucket_name, source_file, destination_file]):
        print("Missing required environment variables.")
        sys.exit(1)

    if os.path.isdir(source_file):
        for file in os.listdir(source_file):
            sourceFile = os.path.join(source_file, file)
            destinationFile = f"{destination_file}/{file}"
            upload(endpoint, access_key, secret_key, bucket_name, destinationFile, sourceFile)
    else:
        upload(endpoint, access_key, secret_key, bucket_name, destination_file, source_file)
        