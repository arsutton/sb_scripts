#!/bin/bash

backup_folder=/home/steam/sbbackups


function get_date_from_path() {

    backup_path="$1"

    if [ -f "$backup_path" ]; then

        timestamp_string=$( echo $backup_path | cut -d - -f -3 | cut -d . -f 2- )
        echo $timestamp_string
         
        date -d "$timestamp_string" +


    fi

}

pushd $backup_folder > /dev/null

for directory in `ls`; do

    get_date_from_path $directory

done

popd > /dev/null
