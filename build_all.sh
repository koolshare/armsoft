#!/bin/bash

#CURR_PATH=$(pwd)
CURR_PATH="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"
cd ${CURR_PATH}

modules=$(find . -maxdepth 1 -type d | grep -iv "\.\/\."|sed 's/.\///g'|sed '/\./d')
for module in ${modules}; do
	#echo ${module}
	if [ -f ${CURR_PATH}/${module}/build.sh ]; then
		echo "add .valid to ${module}"
		echo arm384 > ${CURR_PATH}/${module}/${module}/.valid
		
		echo "build ${module}"
		cd ${CURR_PATH}/${module}
		sh build.sh >/dev/null 2>&1
		cd ..
	else
		echo "${module}: this module do not have build.sh script!"
	fi
done
