#!/bin/bash
  
image="mikeah/prusaslicer-novnc"  
  
# Set the timestamp
timestamp=$(date +%Y.%m.%d.%H%M%S)  
  
tag=$image:$timestamp  
latest=$image:latest  
  
# Build the image -- tagged with the timestamp.
docker build -t $tag -t $latest .  
  
# Push with the timestamped tag, and latest image tag to Docker Hub.
docker login
docker push $tag
docker push $latest
  
# Cleanup
docker system prune -f