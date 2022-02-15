#!/bin/bash

# if parameter --dry-run set DRY to true
if [ "$1" == "-d" ] || [ "$1" == "--dry-run" ]; then
  DRY=true
else
  DRY=false
fi

# loop through all the images.yml files in the directory modules
for f in modules/*/images.yml
do
  # if the file exists
  if [ -f "$f" ]
  then
    # run the sync script
    ./single_sync.sh $f $DRY
  fi
done
