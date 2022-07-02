#!/bin/bash
#Gets called once per image. Use this script to run any programs you'd like on your image prior to import
set -e

#gather title info
filename=${1##*/}
parentPath=${1%/*}
dataset=${parentPath##*/}

#mv to tmp directory (to avoid multiple calls on same file) 
/docker/log.sh INFO "PROCESSING $filename"
mkdir -p /tmp/PROCESSING && mv $1 /tmp/PROCESSING
currentImg=/tmp/PROCESSING/$filename

# if it's in the override pipe, don't run hqc
[[ $2 =~ override|OVERRIDE ]] || \
/docker/hqcPipe.sh $currentImg ${2%/} 

#hqc will throw an error code if bad happened
[[ $? != 0 ]] && /docker/log.sh ERROR "$2: failed with code $?" && exit 1

#convert to zarr
[[ $CONVERT_TO_ZARR ]] && /docker/log.sh INFO "converting to zarr" && \
        /docker/bin/bioformats2raw "$currentImg" "/out/$2/$dataset/${filename%.*}/" $BF2RAW_ARGS && \
        /docker/log.sh INFO "converted to zarr" 

#convert to ome.tiff
[[ $CONVERT_TO_TIFF ]] && /docker/log.sh INFO "converting to ome.tiff" && \
    /docker/bin/bioformats2raw --log-level WARN "$currentImg" "/tmp/$filename/" $BF2RAW_ARGS && \
    mkdir -p "/out/$2/$dataset/" && /docker/log.sh INFO "converted to zarr" && \
    /docker/bin/raw2ometiff --log-level WARN "/tmp/$filename/" "/out/$2/$dataset/${filename%.*}.ome.tiff" $RAW2TIFF_ARGS && \
    /docker/log.sh INFO "converted to ome.tiff"


#zip and archive (medusa?siren? wherever rsync goes now.)
[[ $ARCHIVE_ORIGINAL ]] && /docker/archiveWSI.sh $currentImg ${2%/} $parentPath

#these files are huge, cannot afford to keep them kicking around
/docker/log.sh INFO "cleaning /tmp" && rm -r /tmp/*
