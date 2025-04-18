#!/bin/bash

# Script to build Kubernetes manifests using Kustomize with Helm support.
# Usage: ./build.sh <BUILD_ENV> <KUBE_VERSION>
#   BUILD_ENV: 'staging' or 'production'
#   KUBE_VERSION: Kubernetes version in major.minor[.patch] format.

set -euo pipefail

# Function to display usage information.
usage() {
  echo "Usage: $0 <BUILD_ENV> <KUBE_VERSION>" >&2
  echo "  BUILD_ENV: 'staging' or 'production'" >&2
  echo "  KUBE_VERSION: Kubernetes version in major.minor[.patch] format" >&2
  exit 1
}

# Validate number of arguments.
if [[ $# -ne 2 ]]; then
  echo "Error: Incorrect number of arguments." >&2
  usage
fi

BUILD_ENV="$1"
KUBE_VERSION="$2"

# Validate BUILD_ENV.
if [[ "${BUILD_ENV}" != 'staging' && "${BUILD_ENV}" != 'production' ]]; then
  echo "Error: BUILD_ENV must be either 'staging' or 'production'." >&2
  usage
fi

# Validate KUBE_VERSION format (major.minor or major.minor.patch).
if ! [[ "${KUBE_VERSION}" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
  echo "Error: KUBE_VERSION must be in major.minor[.patch] format (e.g., 1.21 or 1.21.1)." >&2
  usage
fi

# Determine the script's directory to set the project root.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "${SCRIPT_DIR}")"

# Define paths.
SRC_DIR="${PROJECT_ROOT}/src"
BUILD_DIR="${PROJECT_ROOT}/build"
ENV_SRC_DIR="${SRC_DIR}/${BUILD_ENV}"
ENV_BUILD_DIR="${BUILD_DIR}/${BUILD_ENV}"

# Check if source directory exists for the specified environment.
if [[ ! -d "${ENV_SRC_DIR}" ]]; then
  echo "Error: Source directory for environment '${BUILD_ENV}' does not exist at ${ENV_SRC_DIR}." >&2
  exit 1
fi

# Clean the build directory for the specified environment.
echo "Cleaning build directory for ${BUILD_ENV} at ${ENV_BUILD_DIR}..."
if [[ -d "${ENV_BUILD_DIR}" ]]; then
  rm -rf "${ENV_BUILD_DIR}"/*
  echo "Cleaned existing build directory."
else
  mkdir -p "${ENV_BUILD_DIR}"
  echo "Created build directory."
fi

# Check if kustomize is installed.
if ! command -v kustomize &> /dev/null; then
  echo "Error: 'kustomize' is not installed. Please install it first." >&2
  exit 1
fi

# Build manifests for each app in the specified environment.
echo "Building manifests for environment: ${BUILD_ENV} with Kubernetes version: ${KUBE_VERSION}"
for app_dir in "${ENV_SRC_DIR}"/*; do
  if [[ -d "${app_dir}" ]]; then
    app_name="$(basename "${app_dir}")"
    output_dir="${ENV_BUILD_DIR}/${app_name}"
    echo "Processing app: ${app_name}"
    mkdir -p "${output_dir}"
    if ! kustomize build --enable-helm --helm-kube-version "${KUBE_VERSION}" --output "${output_dir}/" "${app_dir}"; then
      echo "Error: Failed to build manifests for app '${app_name}' in environment '${BUILD_ENV}'." >&2
      exit 1
    fi
    echo "Generated manifests for ${app_name} at ${output_dir}"
  fi
done

echo "Build completed successfully for environment: ${BUILD_ENV}"
exit 0