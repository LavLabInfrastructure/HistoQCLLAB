#!/bin/bash
# This test suite is designed to do one mock pipe run w/ online data
HQCLLAB_DIR=/home/mike/Code/omeroEnv/HistoQCLLAB
# demand root privileges
sudo echo "Testing your garbage edits" || (echo "NEEDS TO BE RUN AS ROOT, NERD" && exit 1)

# build the main dockerfile to base test image off
sudo docker build -t=mjbarrett/hqcpipe $HQCLLAB_DIR

# run the test docker container
sudo docker build -t=mjbarrett/hqcpipe:mocktest $HQCLLAB_DIR/scripts/test
sudo docker run mjbarrett/hqcpipe:mocktest