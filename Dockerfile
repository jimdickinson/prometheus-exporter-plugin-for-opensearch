# Build stage for OpenSearch Prometheus Exporter plugin
FROM eclipse-temurin:21-jdk AS builder

# Install git for potential version information
RUN apt-get update && apt-get install -y git

# Set the working directory
WORKDIR /plugin-build

# Copy the project files
COPY . .

# Build the plugin using Gradle
RUN ./gradlew clean build -x integTest -x yamlRestTest

# Verify the built artifacts
RUN ls -la build/distributions/

# Create a small final image to hold just the built artifact
FROM alpine:latest

# Create directory for the artifact
RUN mkdir -p /plugins/prometheus-exporter

# Copy the built plugin ZIP from the builder stage
COPY --from=builder /plugin-build/build/distributions/*.zip /plugins/prometheus-exporter/

# Create version file with information about the build
RUN echo "Build date: $(date)" > /plugins/prometheus-exporter/build-info.txt

# Set working directory to the plugins location
WORKDIR /plugins

# Command to show the available plugins (for verification)
CMD ["ls", "-la", "/plugins/prometheus-exporter/"]
