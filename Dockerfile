FROM python:3.9-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    bash gettext git libintl-perl curl jq gcc libffi-dev libssl-dev musl-tools openssl && \
    python3 -m venv --system-site-packages /app/venv && \
    /app/venv/bin/pip install --no-cache-dir --upgrade pip

# Copy necessary files
COPY build.sh .
COPY minio_upload.py .
COPY requirements.txt .
COPY getDynamicVars.sh .
COPY BP-BASE-SHELL-STEPS/ /opt/buildpiper/shell-functions/

# Set execute permissions
RUN chmod +x build.sh minio_upload.py getDynamicVars.sh

# Install Python dependencies inside virtual environment
RUN /app/venv/bin/pip install --no-cache-dir -r requirements.txt

# Set environment variables
ENV MINIO_ENDPOINT="" \
    MINIO_ACCESS_KEY="" \
    MINIO_SECRET_KEY="" \
    MINIO_BUCKET="" \
    MINIO_DEST_PATH="" \
    MINIO_SOURCE_PATH="" \
    SOURCE_JSON_FILE="mavenrepos.json" \
    WORKSPACE="/bp/workspace" \
    ACTIVITY_SUB_TASK_CODE="BP-MinIO-Step" \
    VALIDATION_FAILURE_ACTION="WARNING"

# Use the virtual environment's Python
ENV PATH="/app/venv/bin:$PATH"

# Define the entry point
ENTRYPOINT ["./build.sh"]
