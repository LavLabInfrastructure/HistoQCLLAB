#!/docker/dumb-init /bin/bash
# starts watching each directory of /in/ 
set -e
/docker/log.sh INFO "Started Import Pipeline"

# if logdir is not defined, define it
[[ -z $LOG_DIR ]] && LOG_DIR=/out/log
mkdir -p $LOG_DIR

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
