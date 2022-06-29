#!/docker/dumb-init /bin/bash
# starts watching each directory of /in/ 
set -e
# if logdir is not defined, define it
[[ -z $LOG_DIR ]] && export LOG_DIR=/out/log 
mkdir -p $LOG_DIR 

# now we can log that we started
/docker/log.sh INFO "Started Import Pipeline"

# just export WSI file extensions instead of pasting that garbage everytime
export WSI_EXTENSIONS=".*\.tif$|.*\.tiff$|.*\.svs$|.*\.jpg$|.*\.vsi$"

# watch each subdirectory of /in
cd /in
for d in */; do
    /docker/watchDir.sh $d &
done

# Good Job!
/docker/log.sh INFO "Finished establishing all watches"
wait
