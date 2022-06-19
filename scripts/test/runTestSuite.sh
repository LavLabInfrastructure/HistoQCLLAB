#!/bin/bash
# This test suite is designed to do one mock pipe run w/ online data

# demand root privileges
sudo echo "Testing your garbage edits" || echo "NEEDS TO BE RUN AS ROOT, NERD" && exit 1

# build the main dockerfile to base test image off
sudo docker build -t=mjbarrett/hqcPipe ../../

# run the test docker container
sudo docker run .