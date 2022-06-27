#!/docker/dumb-init /bin/bash
# test the feature not the implementation
##FUNCTIONS
# something to test hqc
hqcValidation() {
    HQC_PASS=1
}

# something to test zarr conversion
zarrValidation() {
    ZARR_PASS=1
}

# something to test a valid tiff conversion
tiffValidation() {
    TIFF_PASS=1
}

# test zip archiving
zipValidation() {
    ARCHIVE_PASS=1
}

# test tarballing
tarValidation() {
    ARCHIVE_PASS=1
}

# test failing screen
failValidation() {
    FAIL_PASS=1
}


##MAIN
# run proposed entrypoint
/docker/entrypoint.sh &

# download a test file
curl -Lqo /in/testStart/000/test.svs https://openslide.cs.cmu.edu/download/openslide-testdata/Aperio/CMU-1.svs 

# watch 
inotifywait -mr /out -e close_write |
    while read dir action file; do
        if [[ -f $file ]]; then
            #fun text to know things are happening
            echo "Watching for pipe products"

            # run tests based on filetype
            [[ $file == *.tsv ]] && hqcValidation $dir$file
            [[ $file == *.ome.tiff ]] && tiffValidation $dir$file
            [[ $dir == */000/test/* ]] && zarrValidation ${dir%/test/*}/test/
            [[ $file == *.zip ]] && zipValidation $dir$file
            [[ $file == *.tar* ]] && tarValidation $dir$file
            [[ $dir == *fail* ]] && failValidation $dir$file 

            # once each flag has been defined, the test has passed
            ([[ $HQC_PASS ]] && [[ $TIFF_PASS ]] && [[ $ARCHIVE_PASS]] && \
                echo "Good Job! You passed" && exit 0) || \
            # or if this is a failure test, only FAIL_PASS should be defined
            ([[ $FAIL_PASS ]] && [[ -z $ARCHIVE_PASS ]] && \
            [[ -z $TIFF_PASS ]] && [[ -z $ZARR_PASS ]] && \
             echo "Good job! You failed correctly!" exit 0)
        fi
    done 