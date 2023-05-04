import sys
import os
import boto3
from datetime import datetime


def main():
    if len(sys.argv) != 2:
        print("Usage: python s3_uploader.py <file_path>")
        sys.exit(1)

    file_path = sys.argv[1]

    # Settings
    aws_access_key_id = "your_access_key_id"
    aws_secret_access_key = "your_secret_access_key"
    bucket_name = "your-bucket-name"
    region = "us-east-1"

    # Generate a unique bucket file name using the input filename and current timestamp
    bucket_file_name = generate_unique_bucket_file_name(file_path)

    session = boto3.Session(
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key,
        region_name=region
    )
    s3 = session.resource('s3')

    try:
        s3.meta.client.upload_file(file_path, bucket_name, bucket_file_name)
        print("File uploaded successfully!")
    except Exception as e:
        print("Failed to upload file to S3:", e)


def generate_unique_bucket_file_name(file_path):
    input_file_name = os.path.basename(file_path)
    current_timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    return f"{current_timestamp}-{input_file_name}"


if __name__ == "__main__":
    main()
