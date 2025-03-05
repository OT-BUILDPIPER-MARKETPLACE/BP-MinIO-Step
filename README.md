# BP-MinIO-Step

This repository contains scripts and functions for creating a BuildPiper step that can upload any file or directory to a MinIO S3 bucket by creating a tarball of that file or directory. It includes shell scripts for setting up the environment and a Python script for performing the upload.

## Setup

* Clone the code available at [BP-MinIO-Step](https://github.com/OT-BUILDPIPER-MARKETPLACE/BP-MinIO-Step)

* Build the docker image
```sh
git submodule init
git submodule update
docker build -t registry.buildpiper.in/minio-uploader:0.0.3 .
```

* Do local testing
```sh
docker run -it --rm -v $PWD:/src -e var1="key1" -e var2="key2" registry.buildpiper.in/minio-uploader:0.0.2
```

* Debug
```sh
docker run -it --rm -v $PWD:/src -e var1="key1" -e var2="key2" --entrypoint sh registry.buildpiper.in/minio-uploader:0.0.2
```

## Directory Structure
```
.
├── BP-BASE-SHELL-STEPS/      # Submodule containing base shell functions
│   ├── functions.sh          # Main entry point for shell function utilities
│   ├── getDataFile.sh        # Functions for fetching data files from metadata of BuildPiper
│   ├── log-functions.sh      # Functions for logging and debug management
│   ├── README.md             # Documentation for base shell functions
├── bp.yaml                   # BuildPiper configuration file
├── build.sh                  # Shell entrypoint script for building and preparing the environment
├── CHANGELOG.md              # Change log for the project
├── Dockerfile                # Dockerfile for building the Docker image
├── getDynamicVars.sh         # Shell script for fetching dynamic variables
├── LICENSE                   # License file
├── minio_upload.py           # Python script for uploading files to MinIO
├── README.md                 # This documentation file
└── requirements.txt          # Python dependencies file
```

## Purpose

This repository is used to create a BuildPiper step that can upload any file or directory to a MinIO S3 bucket by creating a tarball of that file or directory.

## Maintenance

This branch (`main`) is actively maintained by **Mukul Joshi** (GitHub ID: `mukulmj`), who manages the repository on behalf of **Opstree**. It is currently used for **Airtel** projects and may be updated periodically to support the project's evolving needs.