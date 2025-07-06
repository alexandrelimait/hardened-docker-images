#!/bin/bash
set -e

# Test script for building hardened Docker images locally
# This script helps verify that both Node.js and Python images build correctly

echo "🧪 Testing Hardened Docker Image Builds"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to test a build
test_build() {
    local base_image=$1
    local image_type=$2
    local dockerfile=$3
    
    echo -e "\n${YELLOW}Testing $image_type build with base image: $base_image${NC}"
    
    # Determine image name and version
    if [[ "$image_type" == "node" ]]; then
        local image_name="nodejs-hardened-base"
        local version=$(echo "$base_image" | sed 's/node://' | sed 's/:/-/g')
    else
        local image_name="python-hardened-base"
        local version=$(echo "$base_image" | sed 's/python://' | sed 's/:/-/g')
    fi
    
    echo "Image name: $image_name"
    echo "Version: $version"
    echo "Dockerfile: $dockerfile"
    
    # Build the image
    if DOCKER_BUILDKIT=1 docker build \
        --build-arg BASE_IMAGE="$base_image" \
        --build-arg COMMIT_HASH="test-$(date +%s)" \
        --build-arg BUILD_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
        -t "$image_name:$version" \
        -f ".github/.images/$dockerfile" \
        .github/.images; then
        echo -e "${GREEN}✅ Successfully built $image_name:$version${NC}"
        
        # Test that the image runs
        echo "Testing image execution..."
        if docker run --rm "$image_name:$version" echo "Hello from $image_type hardened image"; then
            echo -e "${GREEN}✅ Image runs successfully${NC}"
        else
            echo -e "${RED}❌ Image failed to run${NC}"
            return 1
        fi
        
        # Clean up
        docker rmi "$image_name:$version" >/dev/null 2>&1 || true
    else
        echo -e "${RED}❌ Failed to build $image_name:$version${NC}"
        return 1
    fi
}

# Test Node.js builds
echo -e "\n${YELLOW}Testing Node.js builds...${NC}"
test_build "node:18-alpine" "node" "Dockerfile.node"
test_build "node:20-alpine" "node" "Dockerfile.node"
test_build "node:22-alpine" "node" "Dockerfile.node"

# Test Python builds
echo -e "\n${YELLOW}Testing Python builds...${NC}"
test_build "python:3.11-alpine" "python" "Dockerfile.python"
test_build "python:3.12-alpine" "python" "Dockerfile.python"
test_build "python:3.13-alpine" "python" "Dockerfile.python"

echo -e "\n${GREEN}🎉 All builds completed successfully!${NC}"
echo -e "${YELLOW}You can now run the GitHub Actions workflows to build and push the images.${NC}" 