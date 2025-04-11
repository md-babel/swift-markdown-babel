#!/usr/bin/env bash

# echo "Update '$(basename "${BASH_SOURCE[0]}")' to use your own '--tag' or use the '.github/workflows/docker-push.yaml' GitHub workflow"
# exit 1

set -eo pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")/.." > /dev/null

# Tagging a build:
#   https://docs.docker.com/get-started/docker-concepts/building-images/build-tag-and-publish-an-image/
# Cross-platform building:
#   https://docs.docker.com/build/building/multi-platform/#create-a-custom-builder
docker buildx build \
	   --platform linux/amd64,linux/arm64 \
	   --tag md-babel/swift-markdown-babel \
	   --push \
	   .
