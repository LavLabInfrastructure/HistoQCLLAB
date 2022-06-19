#!/bin/bash
# Handles HQC screening
echo "HQCPIPE"
#initial screen. Requires a valid pixel percentage 
[[ $REQUIRED_PIXEL_PERCENT -gt 0 ]] && [[ $REQUIRED_PIXEL_PERCENT -lt 101 ]] && \
    python -m histoqc --force -n 1 -o /tmp/$2/screen/ $1

#determine if it passes (just using remaining tissue percentage)
screenScore=$(/docker/getHQCStat.sh ${1##*/} remaining_tissue_percent /tmp/$2/screen/results.tsv)
screenScoreInteger=$( awk -v v=$screenScore 'BEGIN{ printf("%.0f\n", v*100)}')

#if results aren't within spec run report script and exit
[[ $screenScoreInteger -lt $REQUIRED_PIXEL_PERCENT ]] && \
    /docker/reportWSI.sh $1 && exit 1 || exit 0