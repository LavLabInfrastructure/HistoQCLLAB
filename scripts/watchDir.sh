#!/bin/bash
# watches a directory from /in for files added while server is up and uses that as context for histoqc processing
# ex. watchDir brain ; will watch /in/brain for files then pass "brain" to processImage for the correct pipeline 
echo "WATCHING"
inotifywait -mr $IN_DIR/$1 -e close_write |
	while read dir action file; do
		[[ file == .* ]] && exit 0
		#if [[ -f file ]]; then #TODO: accurate if statement
			echo "$file in $dir was $action"
			echo "${dir}${file} was TOTALLY sent to omero"
			/docker/processImage.sh "${dir}${file}" $1 && wait
		#fi
	done