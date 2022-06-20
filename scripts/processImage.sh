#!/bin/bash
#Gets called once per image. Use this script to run any programs you'd like on your image prior to import
set -e
echo "PROCESSING"

#gather title info
filename=${1##*/}
parentPath=${1%/*}
dataset=${parentPath##*/}

#mv to tmp directory (to avoid multiple calls on same file) 
mkdir -p /tmp/PROCESSING && mv $1 /tmp/PROCESSING
currentImg=/tmp/PROCESSING/$filename
echo $currentImg

#runs HQC as ordered
/docker/hqcPipe.sh $currentImg ${2%/} 
#hqc will throw an error code if bad happened
[[ $? != 0 ]] && echo "$2:FAILED" && exit $? 

# just in case a picture gets ran twice, remove the first instance to put it back in
# is it inefficient? maybe... maybe not
tiffcomment $currentImg | sed s/"Resolution = 0.20 um\nAppMag = 40x"/"Resolution = 0.20 um"/ | tiffcomment -set - $currentImg

#Huron does not include appmag, if it is .2 um it is likely 40x
tiffcomment $currentImg | sed s/"Resolution = 0.20 um"/"Resolution = 0.20 um\nAppMag = 40x"/ | tiffcomment -set - $currentImg

# if [[ $CONVERT_TO_TIFF ]]; then
#     /bf2raw/*/bin/bioformats2raw -p --debug=ALL "$currentImg" "/tmp/$filename/" $BF2RAW_ARGS
#     echo "converted to raw"
#     mkdir -p "/out/${2}${dataset}/"
#     /raw2ometiff/*/bin/raw2ometiff -p --debug=ALL "/tmp/$filename/" "/out/$2/${dataset}/${filename%.tif}.ome.tiff" $RAW2TIFF_ARGS 
#     echo "converted to ome.tiff"
# fi

#convert to zarr
[[ $CONVERT_TO_ZARR ]] && echo "converting to zarr" && mkdir "/out/$2/$dataset/$filename/" && \
        /docker/bin/bioformats2raw "$1" "/out/$2/$dataset/$filename/" $BF2RAW_ARGS && echo "converted to raw" 

#convert to ome.tiff
[[ $CONVERT_TO_TIFF ]] && echo "converting to ome.tiff" && \
    /docker/bin/bioformats2raw --debug=WARN "$currentImg" "/tmp/$filename/" $BF2RAW_ARGS && \
    mkdir -p "/out/$2/$dataset/" && echo "converted to raw" && \
    /docker/bin/raw2ometiff --debug=WARN "/tmp/$filename/" "/out/$2/$dataset/${filename%.tif}.ome.tiff" $RAW2TIFF_ARGS && \
    echo "converted to ome.tiff"


#zip and archive (medusa?siren? wherever rsync goes now.)
[[ $ARCHIVE_ORIGINAL ]] && /docker/archiveWSI.sh $currentImg ${2%/}

#these files are huge, cannot afford to keep them kicking around
rm -r /tmp/*