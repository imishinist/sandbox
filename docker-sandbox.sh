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

# Mount home directory as read-only
docker_options+=("--volume=${HOME}:${HOME}:ro")

# Grant write access to specific directories (only if they exist)
if [ -d "${HOME}/.config" ]; then
    docker_options+=("--volume=${HOME}/.config:${HOME}/.config:rw")
fi
if [ -d "${HOME}/.cache" ]; then
    docker_options+=("--volume=${HOME}/.cache:${HOME}/.cache:rw")
fi

# AWS Q specific directories (if they exist)
if [ -d "${HOME}/.aws/amazonq" ]; then
    docker_options+=("--volume=${HOME}/.aws/amazonq:${HOME}/.aws/amazonq:rw")
fi
if [ -d "${HOME}/.local/share/amazon-q" ]; then
    docker_options+=("--volume=${HOME}/.local/share/amazon-q:${HOME}/.local/share/amazon-q:rw")
fi

# Environment variables
docker_options+=("--env=PATH=${PATH}")
docker_options+=("--env=HOME=${HOME}")
docker_options+=("--env=USER=${USER_NAME}")
docker_options+=("--env=TERM=${TERM:-xterm}")

# Resource limits
docker_options+=('--memory=1g')
docker_options+=('--cpus=1.0')

# Additional security options
docker_options+=('--security-opt=apparmor:docker-default')

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
