#!/bin/bash

source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh
source /opt/buildpiper/shell-functions/getDataFile.sh
source /opt/buildpiper/shell-functions/getDynamicVars.sh

TASK_STATUS=0

# Main logic to check conditions and call fetch_service_details
if [ -n "$SOURCE_VARIABLE_REPO" ]; then
    # Check if MINIO_ACCESS_KEY and MINIO_SECRET_KEY are provided
    if [ -n "$MINIO_ACCESS_KEY" ] && [ -n "$MINIO_SECRET_KEY" ]; then
        echo "MINIO_ACCESS_KEY and MINIO_SECRET_KEY are provided. Skipping fetching details from SOURCE_VARIABLE_REPO."
    else
        echo "Fetching details from $SOURCE_VARIABLE_REPO as MINIO_ACCESS_KEY and MINIO_SECRET_KEY are not provided."
        fetch_service_details
    fi
else
    logErrorMessage "SOURCE_VARIABLE_REPO is not defined. Skipping fetching details from $SOURCE_VARIABLE_REPO."
fi

CODEBASE_LOCATION="${WORKSPACE}"/"${CODEBASE_DIR}"
logInfoMessage "I'll do processing at [$CODEBASE_LOCATION]"
sleep  $SLEEP_DURATION
cd "${CODEBASE_LOCATION}"

# Trigger `minio_upload.py` if required
if [ "$TASK_STATUS" -eq 0 ]; then
    logInfoMessage "Triggering minio_upload.py..."
    python3 minio_upload.py || { logErrorMessage "Failed to execute minio_upload.py"; exit 1; }
else
    logErrorMessage "Skipping minio_upload.py due to task failure."
fi

saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}