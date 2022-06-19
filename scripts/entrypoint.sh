#!/docker/dumb-init /bin/bash
#starts watching each directory of /in/ 
set -e
echo "ENTRY"
mkdir -p /tmp/PROCESSING
cd $IN_DIR
for d in */; do
    /docker/watchDir.sh $d &
done
wait
