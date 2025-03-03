FROM minio/minio:latest

WORKDIR /app

# Install bash, curl, and other dependencies
RUN apk add --no-cache --upgrade bash \
    gettext \
    git \
    libintl \
    curl \
    jq \
    python3 \
    py3-pip \
    gcc \
    libffi-dev \
    musl-dev \
    openssl-dev \
    python3-dev \
    make

# Create a Python virtual environment
RUN python3 -m venv /app/venv

# Copy the Bash script into the Docker image
COPY build.sh .
COPY minio_upload.py .
COPY requirements.txt .
COPY getDynamicVars.sh .
COPY BP-BASE-SHELL-STEPS/ .

# Install required dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Set environment variables for script arguments

ENV TELEGRAM_TOKEN ""
ENV TELEGRAM_CHAT_ID ""
ENV DNS_URL ""
ENV MINIO_ACCESS_KEY ""
ENV MINIO_SECRET ""
ENV MINIO_BUCKET_NAME ""
ENV MINIO_ENDPOINT ""
ENV MINIO_PORT ""
ENV ACTIVITY_SUB_TASK_CODE BP-MinIO-Step
ENV VALIDATION_FAILURE_ACTION WARNING

# Use the virtual environment's Python for the container
ENV PATH="/app/venv/bin:$PATH"

# Define the entry point for the Docker container
ENTRYPOINT ["./build.sh"]
