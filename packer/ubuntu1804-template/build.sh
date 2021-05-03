#!/bin/bash


## Remove old files
### Remove old ova
NAME="`cat debian10.json| egrep '"name":' | awk -F ":" '{print $2}' | sed 's/"//g' | sed 's/,//g' | sed 's/ //g'`.ova"
DIRECTORY=`cat debian10.json| egrep 'output_directory' | awk -F ":" '{print $2}' | sed 's/"//g' | sed 's/,//g'`
rm -rf $DIRECTORY/$NAME
## Remove old log file
rm -f build.log


## Generate preseed with strong password
password_root='Analsyte'
password_analyste='Analyste'
sed "s/<password_root>/$password_root/; s/<password_analyste>/$password_analyste/;" ./http/preseed.cfg.tpl > ./http/preseed.cfg

## Generate new ova
export PACKER_LOG=1; packer build ubuntu.json | tee -a build.log

## Remove temp files
rm -rf ./packer_cache
rm -rf ./http/preseed.cfg
