#!/bin/bash
# build script for rogsoft project
DIR="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"
ME=$(basename "$0")
VERSION=1.9.14

echo $VERSION > ./softcenter/.soft_ver

echo build version: ${VERSION}
rm -f softcenter.tar.gz

python ./gen_install.py stage1

chmod 755 ./softcenter/scripts/ks_app_install.sh

# ----------------------------
echo "build softcenter for arm"
rm -rf $DIR/build
mkdir -p $DIR/build
cp -rf ./softcenter ./build/
cd ./build
tar -zcf softcenter.tar.gz softcenter
if [ "$?" = "0" ];then
	echo "build arm success!"
	mv softcenter.tar.gz ..
fi
cd ..
rm -rf ./build
# ----------------------------

md5value=$(md5sum softcenter.tar.gz|awk '{print $1}')
cat > ./version <<EOF
$VERSION
$md5value
EOF

cat version

cat > ./config.json.js <<EOF
{
"version":"$VERSION",
"md5":"$md5value"
}
EOF

python ./gen_install.py stage2

cat to_remove.txt|xargs rm -f
rm to_remove.txt
