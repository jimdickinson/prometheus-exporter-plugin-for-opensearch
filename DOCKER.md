# Docker Build for OpenSearch Prometheus Exporter Plugin

This directory contains Docker configuration files to build and use the OpenSearch Prometheus Exporter plugin. The build process uses JDK 21.

## Files

- `Dockerfile`: Multi-stage build that compiles the plugin and produces a small image containing the plugin ZIP file
- `docker-compose.yml`: Example of how to use the built plugin with an OpenSearch instance

## Building the Plugin Image

To build just the plugin builder image:

```bash
docker build -t prometheus-exporter-plugin:3.0.0.0 .
```

This will create an Alpine-based image that contains the built plugin ZIP file in `/plugins/prometheus-exporter/`.

## Using with Docker Compose

The provided Docker Compose configuration demonstrates a complete workflow:

1. Building the plugin
2. Making it available via a shared volume
3. Having OpenSearch install the plugin during startup

To run the full setup:

```bash
# For default versions (OpenSearch 3.0.0, Plugin 3.0.0.0)
docker-compose up -d

# Or specify versions
OPENSEARCH_VERSION=3.0.0 PLUGIN_VERSION=3.0.0.0 docker-compose up -d
```

## Accessing the Prometheus Metrics

Once the containers are running, you can access the Prometheus metrics at:

```
http://localhost:9200/_prometheus/metrics
```

## Using in a Custom Dockerfile

To use the built plugin in your own custom Dockerfile:

```dockerfile
# First stage - build the plugin
FROM prometheus-exporter-plugin:3.0.0.0 AS plugin

# Second stage - use in OpenSearch
FROM opensearchproject/opensearch:3.0.0

# Copy the plugin from the builder image
COPY --from=plugin /plugins/prometheus-exporter/prometheus-exporter-*.zip /tmp/

# Install the plugin
RUN bin/opensearch-plugin install file:///tmp/prometheus-exporter-*.zip

# Remove the ZIP file as it's no longer needed
RUN rm /tmp/prometheus-exporter-*.zip
```

## Notes

- The plugin version must match the OpenSearch version (major.minor.patch)
- The Docker build runs unit tests but skips integration tests (integTest, yamlRestTest) to avoid issues with OpenSearch refusing to run as root
- For production use, consider pinning to specific versions
