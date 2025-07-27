#!/bin/bash

set -e

WORKING_DIR=$(pwd)
USER_ID=$(id -u)
GROUP_ID=$(id -g)
USER_NAME=$(whoami)

# Docker run options for security
docker_options=()

# Basic container settings
docker_options+=('--rm')  # Remove container after exit
docker_options+=('--interactive')
docker_options+=('--tty')

# Security options
docker_options+=('--security-opt=no-new-privileges:true')  # NoNewPrivileges equivalent
docker_options+=('--cap-drop=ALL')  # Drop all capabilities
docker_options+=('--read-only')  # Read-only root filesystem
docker_options+=('--tmpfs=/tmp:noexec,nosuid,nodev,size=100m')  # Private tmp
docker_options+=('--tmpfs=/var/tmp:noexec,nosuid,nodev,size=100m')
docker_options+=('--tmpfs=/run:noexec,nosuid,nodev,size=100m')

# User mapping
docker_options+=("--user=${USER_ID}:${GROUP_ID}")

# Network restrictions
docker_options+=('--network=bridge')

# Mount current working directory as read-write
docker_options+=("--volume=${WORKING_DIR}:${WORKING_DIR}:rw")
docker_options+=("--workdir=${WORKING_DIR}")


# Create writable home directory with tmpfs
docker_options+=("--tmpfs=${HOME}:noexec,nosuid,nodev,size=500m")

# Mount essential read-only files from host home
essential_files=(
    ".bashrc"
    ".bash_profile"
    ".profile"
    ".gitconfig"
)

for file in "${essential_files[@]}"; do
    if [ -e "${HOME}/${file}" ]; then
        docker_options+=("--volume=${HOME}/${file}:${HOME}/${file}:ro")
    fi
done

docker_options+=("--volume=/etc/passwd:/etc/passwd:ro")

# Mount writable directories
writable_dirs=(
    ".config"
    ".cache" 
    ".local/share/amazon-q"
    ".aws/amazonq"
)

for dir in "${writable_dirs[@]}"; do
    if [ -d "${HOME}/${dir}" ]; then
        docker_options+=("--volume=${HOME}/${dir}:${HOME}/${dir}:rw")
    fi
done

# Environment variables
docker_options+=("--env=PATH=${PATH}")
docker_options+=("--env=HOME=${HOME}")
docker_options+=("--env=USER=${USER_NAME}")
docker_options+=("--env=TERM=${TERM:-xterm}")

# Resource limits
docker_options+=('--memory=1g')
docker_options+=('--cpus=1.0')

# Additional security options (AppArmor is not available on macOS)
# docker_options+=('--security-opt=apparmor:docker-default')

# Set hostname to prevent information leakage
docker_options+=('--hostname=sandbox')

# Use custom image with Amazon Q CLI
IMAGE="sandbox-amazonq:latest"

# Check if image exists, if not build it
if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
    echo "Building Docker image: $IMAGE"
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    docker build -t "$IMAGE" "$SCRIPT_DIR"
fi

# Create a temporary container name
TEMP_CONTAINER_NAME="sandbox-temp-$(date +%s)"

# Create and start container
exec docker run \
    "${docker_options[@]}" \
    --name="$TEMP_CONTAINER_NAME" \
    "$IMAGE" \
    "$@"
