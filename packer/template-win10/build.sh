#!/bin/bash


## Remove old files
### Remove old ova
NAME="`cat win10.json| egrep '"name":' | awk -F ":" '{print $2}' | sed 's/"//g' | sed 's/,//g' | sed 's/ //g'`.ova"
DIRECTORY=`cat win10.json| egrep 'output_directory' | awk -F ":" '{print $2}' | sed 's/"//g' | sed 's/,//g'`
rm -rf $DIRECTORY/$NAME

## Generate new ova
date  | tee -a build.log; export PACKER_LOG=1; packer build -var-file=../variables.json  win10.json | tee -a build.log; date | tee build.log

## Remove temp files
rm -rf ./packer_cache
