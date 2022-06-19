#!/bin/bash
#zip original files and send to dropbox or something
echo "ARCHIVE"
#if ARCHIVE_ADDRESS is defined let them know  it's not a feature
if [[ $ARCHIVE_ADDRESS ]]; then
    echo "network archiving is not implemented loser"
else # else zip and send to ARCHIVE_DIR
    #Define archive if it hasn't been
    [[ -z $ARCHIVE_DIR ]] && ARCHIVE_DIR = "/out/archive"
    #if a zip already exists, just update it, else create a zip
    [[ -e $ARCHIVE_DIR/$2 ]] && zip -fug $ARCHIVE_DIR/$2 $1 && echo "ARCHIVE SUCCESSFUL" || \
        zip -g $ARCHIVE_DIR/$2 $1 && echo "ARCHIVE SUCCESSFUL"
fi