# **Change Log for Docker Image: `registry.buildpiper.in/minio-uploader:0.0.1`**  

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

### **Change Log for Docker Image: `registry.buildpiper.in/minio-uploader:0.0.2`**  

---

**Version:** `registry.buildpiper.in/minio-uploader:0.0.2`  
**Release Date:** `2025-03-05`  
**Maintainer:** *[Mukul Joshi](mukul.joshi@opstree.com), [GitHub](https://github.com/mukulmj)*  

## Added

- **Automated tarball creation:** The shell script now automatically compresses `MINIO_SOURCE_PATH` (file or directory) into a `.tar.gz` archive before uploading.  
- **Dynamic destination path handling:** Ensures `BUILD_NUMBER` is retained in `MINIO_DEST_PATH`, preventing overwrites between builds.  
- **Improved logging:** Enhanced messages for each step in the upload process to improve debugging and visibility.  

## Changed

- **Refactored `minio_upload.py`:** Now correctly handles directory uploads by iterating over files and preserving the correct destination structure.  
- **Better error messages:** Includes detailed logging for failures in `minio_upload.py` to identify missing variables or incorrect paths.  
- **Optimized tar command:** The script ensures the archive is created in the correct location and includes only the necessary files.  

## Fixed

- **Resolved issue with `BUILD_NUMBER` being overwritten:** The `MINIO_DEST_PATH` now retains the full directory structure, preventing file conflicts.  
- **Fixed missing file validation:** Ensures that `MINIO_SOURCE_PATH` exists before creating an archive.  
- **Handled permission errors:** The script now checks write permissions before attempting tarball creation.  

---

### **Change Log for Docker Image: `registry.buildpiper.in/minio-uploader:0.0.3`**  

---

**Version:** `registry.buildpiper.in/minio-uploader:0.0.3`  
**Release Date:** `2025-03-05`  
**Maintainer:** *[Mukul Joshi](mukul.joshi@opstree.com), [GitHub](https://github.com/mukulmj)*  

## **Added**  

- **Report Publishing to Workspace Publisher:**  
  - Logs report update using:  

    ```bash
    logInfoMessage "Updating reports in /bp/execution_dir/${GLOBAL_TASK_ID}......."
    cp -rf reports/* /bp/execution_dir/${GLOBAL_TASK_ID}/
    ```  

  - Ensures reports are available for workspace publishing.  

## **Changed**  

- **Updated Logging & Validation:**  
  - Logs messages when reports are copied for better visibility.  

## **Fixed**  

- **Ensured Report Directory is Updated Correctly:**  
  - Copies reports reliably to `/bp/execution_dir/${GLOBAL_TASK_ID}/`.  

---
