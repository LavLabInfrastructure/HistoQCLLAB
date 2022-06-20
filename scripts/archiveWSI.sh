#!/bin/bash
#zip original files and send to dropbox or something
/scripts/log.sh INFO "ARCHIVE"
#if ARCHIVE_ADDRESS is defined let them know  it's not a feature
if [[ $ARCHIVE_ADDRESS ]]; then
    /scripts/log.sh ERROR "network archiving is not implemented loser"
else # else zip and send to ARCHIVE_DIR
    #Define archive if it hasn't been
    [[ -z $ARCHIVE_DIR ]] && ARCHIVE_DIR = "/out/archive"
    #if a zip already exists, just update it, else create a zip
    [[ -e $ARCHIVE_DIR/$2 ]] && zip -fug $ARCHIVE_DIR/$2 $1 && /scripts/log.sh INFO "ARCHIVE of $1 SUCCESSFUL" || \
        zip -g $ARCHIVE_DIR/$2 $1 && /scripts/log.sh INFO "ARCHIVE OF $1 SUCCESSFUL" || \
        /scripts/log.sh ERROR "ARCHIVE OF $1 FAILED"
fi