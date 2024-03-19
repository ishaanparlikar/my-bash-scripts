#!/bin/bash

# Clear Docker container logs
docker container prune -f

# Clear unused Docker images
docker image prune -a --filter "label!=latest" -f
