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

# Mount current working directory as read-write (skip if same as HOME for security)
if [ "${WORKING_DIR}" != "${HOME}" ]; then
    docker_options+=("--volume=${WORKING_DIR}:${WORKING_DIR}:rw")
    docker_options+=("--workdir=${WORKING_DIR}")
else
    echo "WARNING: Running from HOME directory (${HOME}). Working directory will not be mounted for security reasons." >&2
    echo "WARNING: Files in HOME will be stored in temporary memory and lost after exit." >&2
    docker_options+=("--workdir=${WORKING_DIR}")
fi

# Create writable home directory with tmpfs
docker_options+=("--tmpfs=${HOME}:noexec,nosuid,nodev,size=500m,uid=${USER_ID},gid=${GROUP_ID}")

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

# Mount writable directories
writable_dirs=(
    ".config"
    ".cache"
    ".aws/amazonq"
)

for dir in "${writable_dirs[@]}"; do
    if [ -d "${HOME}/${dir}" ]; then
        docker_options+=("--volume=${HOME}/${dir}:${HOME}/${dir}:rw")
    fi
done
# Mount Amazon Q data directory (OS-specific paths)
if [[ "$(uname -s)" == "Darwin" ]]; then
    # macOS
    if [ -d "${HOME}/Library/Application Support/amazon-q" ]; then
        docker_options+=("--volume=${HOME}/Library/Application Support/amazon-q:${HOME}/.local/share/amazon-q:rw")
    fi
else
    # Linux and other Unix-like systems
    if [ -d "${HOME}/.local/share/amazon-q" ]; then
        docker_options+=("--volume=${HOME}/.local/share/amazon-q:${HOME}/.local/share/amazon-q:rw")
    fi
fi

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
    # Get the real path of the script, resolving symlinks (macOS compatible)
    SCRIPT_PATH="${BASH_SOURCE[0]}"
    while [ -L "$SCRIPT_PATH" ]; do
        SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
        # Handle relative symlinks
        if [[ "$SCRIPT_PATH" != /* ]]; then
            SCRIPT_PATH="$(dirname "${BASH_SOURCE[0]}")/$SCRIPT_PATH"
        fi
    done
    SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
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
