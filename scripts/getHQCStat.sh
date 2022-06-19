#!/bin/bash
##FUNCTIONS
#uses awk to grab a specific datapoint from tsv file
#ie: getValue 185_S20.tif pixels_to_use /tmp/pipe/results.tsv
getValue() {
    awk 'BEGIN {
            FS="\t"
        } NR==6 {
            for ( i = 1; i <= NF; i++ ) {
                ix[$i] = i
            } 
        } NR > 6 {
            if ($1 == key) {
                print $ix[value]
            } 
        }' key=$1 value=$2 $3 
}
##MAIN
#print use template if no args supplied
[[ -z $* ]] && echo "getHQCStat.sh {filename} {hqc value name} {hqc results.tsv file}"
# input validation
[[ $1 != *.tif ]] && echo "getHQCStat was expecting to know which slide you wanted data from" && exit 1 
[[ -z $2 ]] && echo "get HQCStat was expecting a key to find a value" && exit 1
([[ ! -e $3 ]] || [[ $3 != */results.tsv ]]) && echo "getHQCStat was expecting a 'results.tsv' file, something went wrong" && exit 1
#"return" hqc value
echo $(getValue $1 $2 $3)