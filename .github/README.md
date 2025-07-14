# GitHub Actions Workflows

This directory contains GitHub Actions workflows for the OpenSearch Prometheus Exporter plugin.

## Workflows

### docker-publish.yml

This workflow builds and publishes the plugin Docker image to GitHub Container Registry (GHCR).

#### Features

- Manually triggered workflow (via workflow_dispatch)
- Builds the plugin Docker image using JDK 21
- Publishes the image to GHCR with appropriate version tags
- Optionally tags the image as 'latest'
- Uses GitHub Actions caching to speed up builds

#### Configuration

When manually triggering the workflow, you can provide the following inputs:

- **tag_version**: Custom version tag for the Docker image (defaults to version in gradle.properties)
- **publish_latest**: Whether to also tag the image as 'latest' (defaults to false)

#### Requirements

The workflow requires the following permissions:

- `contents: read` - To checkout the repository
- `packages: write` - To push to GitHub Container Registry

The default `GITHUB_TOKEN` is used for authentication, so no additional secrets are required.

#### Usage

See the [Docker documentation](../../DOCKER.md#github-container-registry) for details on how to use this workflow and the published images.
