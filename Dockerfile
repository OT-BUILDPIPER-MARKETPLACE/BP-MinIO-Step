FROM alpine:latest

# Install dependencies
RUN apk add --no-cache --upgrade \
    bash gettext git libintl curl jq \
    python3 py3-pip python3-dev \
    gcc libffi-dev musl-dev openssl-dev && \
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
    ACTIVITY_SUB_TASK_CODE="BP-MinIO-Step" \
    VALIDATION_FAILURE_ACTION="WARNING"

# Use the virtual environment's Python
ENV PATH="/app/venv/bin:$PATH"

# Define the entry point
ENTRYPOINT ["./build.sh"]
