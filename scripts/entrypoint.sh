#!/docker/dumb-init /bin/bash
#starts watching each directory of /in/ 
set -e
#if logdir is not defined, define it
[[ -z $LOG_DIR ]] && LOG_DIR=/out/log
mkdir -p $LOG_DIR
/scripts/log.sh INFO "Started Import Pipeline"
cd /in
for d in */; do
    /docker/watchDir.sh $d &
done
/scripts/log.sh INFO "Finished establishing all watches"
wait
