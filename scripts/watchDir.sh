#!/bin/bash
# watches a directory from /in for files added while server is up and uses that as context for histoqc processing
# ex. watchDir brain ; will watch /in/brain for files then pass "brain" to processImage for the correct pipeline 
/scripts/log.sh INFO "WATCHING DIRECTORIES"
cd /in
inotifywait -mr $1 -e close_write |
	while read dir action file; do
		if [[ "$file" =~ .*\.tif$|.*\.tiff$|.*\.svs$|.*\.jpg$|.*\.vsi$ ]]; then 
			/scripts/log.sh INFO "file: $file in: $dir was: $action"
			/docker/processImage.sh "${dir}${file}" $1 && wait
		else
			/scripts/log.sh WARN "$dir$file was ignored" && exit 0
		fi
	done