#!/bin/bash

## Remove old files
rm -rf ./win10
## Build machine
export PACKER_LOG=1; packer build win10.json | tee build.log

if [ $? -ne 0 ]; then
  echo "Packer [template-cuckoo_win10] : Failure"
  tail -n20 build.log
else
  echo "Packer [template-cuckoo_win10] : Success"
  #rm -f build.log
fi


## Flush memory cache
echo 3 | sudo tee /proc/sys/vm/drop_caches 1>/dev/null

## Remove cache directory
rm -rf ./packer_cache
