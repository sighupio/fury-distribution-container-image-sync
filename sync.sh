#!/bin/bash

# loop through all the images.yml files in the directory modules
for f in modules/*/images.yml
do
  # if the file exists
  if [ -f "$f" ]
  then
    # run the sync script
    ./single_sync.sh $f
  fi
done
