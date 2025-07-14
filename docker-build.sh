#!/bin/bash

# Script to build and use Docker images for OpenSearch Prometheus Exporter plugin
# Uses JDK 21 for building

# Default versions
OPENSEARCH_VERSION=${OPENSEARCH_VERSION:-"3.0.0"}
PLUGIN_VERSION=${PLUGIN_VERSION:-"3.0.0.0"}

# Print current configuration
echo "Building for:"
echo "  OpenSearch version: $OPENSEARCH_VERSION"
echo "  Plugin version: $PLUGIN_VERSION"
echo ""

# Build plugin image
build_plugin() {
    echo "Building plugin image..."
    echo "Note: Unit tests will run, but integration tests (integTest, yamlRestTest) are skipped to avoid issues with OpenSearch refusing to run as root"
    docker build -t prometheus-exporter-plugin:${PLUGIN_VERSION} .
    echo "Build complete. Image: prometheus-exporter-plugin:${PLUGIN_VERSION}"
}

# Build OpenSearch with plugin
build_opensearch_with_plugin() {
    echo "Building OpenSearch image with plugin..."
    docker build \
        --build-arg OPENSEARCH_VERSION=${OPENSEARCH_VERSION} \
        --build-arg PLUGIN_VERSION=${PLUGIN_VERSION} \
        -t opensearch-with-prometheus:${OPENSEARCH_VERSION} \
        -f Dockerfile.opensearch-with-plugin .
    echo "Build complete. Image: opensearch-with-prometheus:${OPENSEARCH_VERSION}"
}

# Run with docker-compose
run_docker_compose() {
    echo "Starting services with docker-compose..."
    OPENSEARCH_VERSION=${OPENSEARCH_VERSION} PLUGIN_VERSION=${PLUGIN_VERSION} docker-compose up -d
    echo "Services started. Check status with 'docker-compose ps'"
}

# Extract plugin ZIP to local filesystem
extract_plugin_zip() {
    echo "Extracting plugin ZIP to local directory..."
    mkdir -p ./build/docker-output
    docker run --rm -v $(pwd)/build/docker-output:/output \
        prometheus-exporter-plugin:${PLUGIN_VERSION} \
        sh -c "cp /plugins/prometheus-exporter/*.zip /output/"
    echo "Plugin ZIP extracted to ./build/docker-output"
}

# Show help
show_help() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  build-plugin               Build only the plugin image"
    echo "  build-opensearch           Build OpenSearch image with plugin pre-installed"
    echo "  run-compose                Run using docker-compose"
    echo "  extract-zip                Extract plugin ZIP to local directory"
    echo "  all                        Execute all build steps"
    echo "  help                       Show this help message"
    echo ""
    echo "Environment variables:"
    echo "  OPENSEARCH_VERSION         OpenSearch version (default: 3.0.0)"
    echo "  PLUGIN_VERSION             Plugin version (default: 3.0.0.0)"
    echo ""
    echo "Note: The build process uses JDK 21 as required by OpenSearch 3.0.0+"
    echo ""
    echo "GitHub Actions:"
    echo "  For automated builds and publishing to GitHub Container Registry,"
    echo "  see the workflow at .github/workflows/docker-publish.yml"
    echo "  and the documentation in DOCKER.md"
}

# Process command line argument
case "$1" in
    "build-plugin")
        build_plugin
        ;;
    "build-opensearch")
        build_opensearch_with_plugin
        ;;
    "run-compose")
        run_docker_compose
        ;;
    "extract-zip")
        extract_plugin_zip
        ;;
    "all")
        build_plugin
        build_opensearch_with_plugin
        extract_plugin_zip
        echo "\nAll builds completed. To run the services:"
        echo "  ./docker-build.sh run-compose"
        ;;
    *)
        show_help
        ;;
esac
