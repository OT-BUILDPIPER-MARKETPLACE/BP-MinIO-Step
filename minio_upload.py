from minio import Minio
import argparse
import os

def parse_args_provision():
    provision_parser = argparse.ArgumentParser(description='change implementation plan', usage="creating implementation plan to raise change")
    try:
        provision_parser.add_argument('-a', '--access_key', help='access_key')
        provision_parser.add_argument('-c', '--secret_key', help='secret_key')
        provision_parser.add_argument('-e', '--endpoint', help='host')
        provision_parser.add_argument('-b', '--bucket_name', help='bucket_name')
        provision_parser.add_argument('-d', '--destination_file', help='destination_file')
        provision_parser.add_argument('-s', '--source_file', help='source_file')
    except Exception as e:
        raise
    return provision_parser.parse_args()

def upload(host, access_key, secret_key, bucket_name, destination_file, source_file):
    try:
        client = Minio(host, access_key,secret_key,secure=False)
        client.fput_object(bucket_name, destination_file, source_file)
        print("{} successfully uploaded as object {} to bucket {}".format(source_file, destination_file, bucket_name))
    except Exception as e:
        print("Error while uploading object in minio -- {}".format(e))

if __name__ == "__main__":
    args = parse_args_provision()
    if os.path.isdir(args.source_file):
        for file in os.listdir(args.source_file):
            sourceFile = os.path.join(args.source_file, file)
            destinatinFile = os.path.join(args.destination_file, file)
            upload(args.endpoint, args.access_key, args.secret_key, args.bucket_name, destinatinFile, sourceFile)
    else:
        upload(args.endpoint, args.access_key, args.secret_key, args.bucket_name, args.destination_file, args.source_file)