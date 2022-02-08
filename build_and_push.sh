#!/bin/bash
  
image="mikeah/prusaslicer-novnc"  
  
# Set the timestamp
timestamp=$(date +%Y.%m.%d.%H%M%S)  
  
tag=$image:$timestamp  
latest=$image:latest  
  
# Build the image -- tagged with the timestamp.
docker build -t $tag .  
  
# Push with the latest tag and the timestamp tag to Docker Hub.
docker login
docker push $latest  
  
# Cleanup
docker system prune -f