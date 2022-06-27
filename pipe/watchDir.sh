#!/bin/bash
# watches a directory from /in for files added while server is up and uses that as context for histoqc processing
# ex. watchDir brain ; will watch /in/brain for files then pass "brain" to processImage for the correct pipeline 
/docker/log.sh INFO "WATCHING DIRECTORIES"
cd /in
inotifywait -mr $1 -e close_write |
	while read dir action file; do
		if [[ "$file" =~ $WSI_EXTENSIONS ]]; then 
			/docker/log.sh INFO "file: $file in: $dir was: $action"
			/docker/processImage.sh "${dir}${file}" $1 && wait
		else
			/docker/log.sh WARN "$dir$file was ignored"
		fi
	done