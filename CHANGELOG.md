# **Change Log for Docker Image: `registry.buildpiper.in/minio-uploader`**  

---

**Version:** `registry.buildpiper.in/minio-uploader:0.0.1`  
**Release Date:** `2025-03-03`  
**Maintainer:** *[Mukul Joshi](mukul.joshi@opstree.com), [GitHub](https://github.com/mukulmj)*  

## Added  

- **Python-based MinIO uploader script:** Uploads files and directories to MinIO using environment variables.  
- **Shell script (`fetch_service_details.sh`):** Fetches service details from a remote repository, extracts secrets, and sets environment variables.  
- **Decryption functionality:** Uses `getDecryptedCredential` to decrypt MinIO credentials before upload.  

## Changed  

- **Optimized repository handling:** Clones only the necessary branch with `--depth 2` for efficiency.  
- **Improved error handling:** Checks for missing environment variables before execution.  
- **Automated cleanup:** Deletes the cloned repository after extracting required data.  

## Fixed  

- **Resolved missing `sys` import in Python script.**  
- **Fixed service name extraction from `deploy_stateless_app`.**  
- **Ensured proper validation of decrypted credentials before upload.**  

---

## **Dockerfile Overview**  

### **Base Image**  

- `python:3.9-slim` – Lightweight Python environment for running the MinIO uploader script.  

### **Installed Binaries & Their Purpose**  

- **`bash`** → Installs Bash shell, useful for running scripts (`build.sh`).
- **`gettext`** → Provides utilities like `envsubst` for environment variable substitution.
- **`git`** → Enables cloning and interacting with Git repositories.
- **`libintl`** → Provides internationalization support (required by `gettext`).
- **`curl`** → Allows making HTTP requests (e.g., fetching files from a URL).
- **`jq`** → A lightweight command-line JSON processor for parsing JSON data.
- **`python3`** → Installs Python 3 (needed for running Python scripts like `minio_upload.py`).
- **`py3-pip`** → Installs `pip`, Python’s package manager for installing dependencies.
- **`python3-dev`** → Provides Python headers needed for compiling some Python packages.
- **`gcc`** → The GNU Compiler Collection, required for building certain Python libraries.
- **`libffi-dev`** → Supports the `cffi` Python module, which is used in cryptographic libraries.
- **`musl-dev`** → Installs the standard C library for Alpine Linux (needed for compiling).
- **`openssl-dev`** → Provides OpenSSL development libraries (used for secure communications, encryption).

### **Entrypoint**  

- The container runs `fetch_service_details.sh` first to retrieve MinIO credentials and then executes the Python uploader script.  

---
