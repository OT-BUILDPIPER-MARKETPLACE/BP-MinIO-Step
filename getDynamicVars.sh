source functions.sh

# Function to clone the repository, extract details, and set environment variables
function fetch_service_details() {
    
    # Repository details
    # local SOURCE_VARIABLE_REPO="https://github.com/buildpipermasterpipeline.git"
    local LOCAL_REPO_DIR="/tmp/buildpipermasterpipeline"

    # Ensure the directory exists
    if [ ! -d "$LOCAL_REPO_DIR" ]; then
        echo "Directory $LOCAL_REPO_DIR does not exist. Creating it..."
        mkdir -p "$LOCAL_REPO_DIR" || { echo "Error: Failed to create directory $LOCAL_REPO_DIR."; return 1; }
    fi

    # Clone the repository directly to the specific branch with a depth of 2
    if [ ! -d "$LOCAL_REPO_DIR/.git" ]; then
        echo "Cloning repository $SOURCE_VARIABLE_REPO into $LOCAL_REPO_DIR on branch $APPLICATION_NAME with depth 2..."

        # Run git clone and capture output and status
        output=$(git clone --branch "$APPLICATION_NAME" --depth 2 "$SOURCE_VARIABLE_REPO" "$LOCAL_REPO_DIR" 2>&1)
        clone_status=$?

        if [ $clone_status -ne 0 ]; then
            echo "Error: Cloning failed with exit code $clone_status. Output: $output"
            return 1
        fi
    else
        echo "Repository already exists. Fetching latest changes..."
        cd "$LOCAL_REPO_DIR" || { echo "Error: Cannot change directory to $LOCAL_REPO_DIR"; return 1; }
        git fetch origin "$APPLICATION_NAME" --depth 2 || { echo "Error: Fetching latest changes failed."; return 1; }
        git pull origin "$APPLICATION_NAME" || { echo "Error: Pulling latest changes failed for branch $APPLICATION_NAME."; return 1; }
    fi

    # Path to the mavenrepos.json file
    local json_file="$LOCAL_REPO_DIR/$SOURCE_JSON_FILE"

    # Check if mavenrepos.json exists
    if [ ! -f "$json_file" ]; then
        echo "Error: $json_file not found for branch $APPLICATION_NAME"
        return 1
    fi

    # Find the service details in the JSON file
    echo "Extracting service details for $CODEBASE_DIR..."

    # Function to get the deployment service name
    function getDeploymentServiceName() {
      DEPLOY_SERVICE_NAME=$(jq -r '.k8s_manifest[] | select(.k8s_manifest_type == "service") | .metadata.name' < /bp/data/deploy_stateless_app)
      echo "$DEPLOY_SERVICE_NAME"
    }

    # Get the deployment service name
    DEPLOY_SERVICE_NAME=`getDeploymentServiceName`

    # Check if CODEBASE_DIR is not set or empty, use getServiceName to get a default value
    if [ -z "$CODEBASE_DIR" ]; then
        CODEBASE_DIR=$(echo "$DEPLOY_SERVICE_NAME" | sed -E 's/-(dev|prod|qa|staging|uat)-.*$//')
        echo "CODEBASE_DIR was empty, using deployment service name: $CODEBASE_DIR"
    fi

    local service_data=$(jq -r --arg CODEBASE_DIR "$CODEBASE_DIR" '.repositories[] | select(.bitbucketRepoName == $CODEBASE_DIR)' "$json_file")

    if [ -z "$service_data" ]; then
        echo "Error: Service $CODEBASE_DIR not found in $json_file"
        return 1
    fi

    # Extract the specific details and export them as environment variables
    export ENCRYPTED_MINIO_ACCESS_KEY=$(echo "$service_data" | jq -r '.ENCRYPTED_MINIO_ACCESS_KEY')
    export ENCRYPTED_MINIO_SECRET_KEY=$(echo "$service_data" | jq -r '.ENCRYPTED_MINIO_SECRET_KEY')

    # Decrypt the token using the getDecryptedCredential function
    MINIO_ACCESS_KEY=$(getDecryptedCredential "$FERNET_KEY" "$ENCRYPTED_MINIO_ACCESS_KEY")
    MINIO_SECRET_KEY=$(getDecryptedCredential "$FERNET_KEY" "$ENCRYPTED_MINIO_SECRET_KEY")

    if [ -z "$MINIO_ACCESS_KEY" ] || [ -z "$MINIO_SECRET_KEY" ]; then
        echo "Error: Failed to decrypt MINIO_ACCESS_KEY or MINIO_SECRET_KEY."
        exit 1
    fi

    export MINIO_ENDPOINT=$(echo "$service_data" | jq -r '.MINIO_ENDPOINT')
    export MINIO_BUCKET=$(echo "$service_data" | jq -r '.MINIO_BUCKET')
    export MINIO_DEST_PATH=$(echo "$service_data" | jq -r '.MINIO_DEST_PATH')
    export MINIO_SOURCE_PATH=$(echo "$service_data" | jq -r '.MINIO_SOURCE_PATH')

    # Remove the cloned repository
    echo "Removing the cloned repository..."
    rm -rf "$LOCAL_REPO_DIR" || { echo "Error: Failed to remove directory $LOCAL_REPO_DIR."; return 1; }

    echo "Environment variables have been set and repository has been removed."
}