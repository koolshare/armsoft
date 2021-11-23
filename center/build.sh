#!/bin/sh

# build script for armsoft project

MODULE="center"
VERSION="1.3"
TITLE="koolcenter 一键切换"
DESCRIPTION="Node.js"
HOME_URL="koolcenter → softcenter 一键切换！"
TAGS="辅助 工具"
AUTHOR="sadog"

# Check and include base
DIR="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"


# now include build_base.sh
. $DIR/../softcenter/build_base.sh

# change to module directory
cd $DIR

# do something here
do_build_result
