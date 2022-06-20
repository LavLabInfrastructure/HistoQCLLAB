#!/docker/dumb-init /bin/bash
#starts watching each directory of /in/ 
set -e
echo "ENTRY"
cd $IN_DIR
for d in */; do
    /docker/watchDir.sh $d &
done
wait
