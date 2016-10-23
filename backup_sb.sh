#!/bin/bash

storage_folder=/home/steam/Steam/steamapps/common/Starbound/storage
backups_folder=/home/steam/sbbackups
date_format="%Y-%m-%d_%H.%M.%S"


function backup() {


    if [ "$1" == "auto" ]; then
        backupstring=AUTO
    elif [ "$1" == "restore" ]; then
        backupstring=RESTORE
    else
        backupstring=BACKUP
    fi

    if [ ! -d $backups_folder ]; then
        mkdir $backups_folder
    fi

    backup_destination=$backups_folder/sb.$(date +"$date_format")-$backupstring.tar.gz

    pushd $storage_folder > /dev/null

    echo Creating backup file
    tar cvfz $backup_destination * > /dev/null

    popd > /dev/null

}

function validate_backupfile() {
    universefound=false
    if [ -f "$1" ]; then

        for foldername in `tar --exclude="*/*" -tf $1 2> /dev/null`; do
            if [ "$foldername" == "universe/" ]; then
                universefound=true
            fi
        done
    fi

    if [ "$universefound" == "true" ]; then
        echo VALID
    else
        echo INVALID
    fi


}

function restore() {

    if [ -f "$1" ]; then

        valid=$( validate_backupfile "$1" )

        if [ "$valid" == "VALID" ]; then

            echo "backup file appears valid. Stopping server" 

            sudo service starbound stop

            echo "copying backup file to a safe location and nuking storage folder"
            
            restore_temp=/tmp/sbrestore_$RANDOM
            mkdir $restore_temp > /dev/null
            
            restore_filename=restore.tgz

            cp "$1" $restore_temp/$restore_filename
            
            backup restore

            echo "nuking..."

            pushd $storage_folder > /dev/null && rm -rf * > /dev/null && popd > /dev/null

            cp $restore_temp/$restore_filename $storage_folder/$restore_filename > /dev/null
            
            pushd $storage_folder > /dev/null

            echo "restoring..."

            tar xvfz $restore_filename > /dev/null
  
            rm $restore_filename

            chown -R steam:steam *

            popd > /dev/null

            rm -rf $restore_temp > /dev/null

            echo Starting server...

            sudo service starbound start

            echo done.
            
        fi

    fi
   
}

function get_date_from_path() {
    backup_path="$1"


    if [ -f "$backup_path" ]; then

        newest_date=

        current_day=
        current_hour_minute=

        # for thing in `tar --exclude="*/*" -vztf $1 2> /dev/null`; do
        for thing in `tar -vztf $1 2> /dev/null`; do
            if [ "$current_day" != "" ]; then
                current_hour_minute=$thing
            fi

            if [[("$current_day" != "") && ("$current_hour_minute" != "")]]; then
                current_date_seconds=$( date -d "$current_day $current_hour_minute" +%s 2> /dev/null )
                if [ "$current_date_seconds" != "" ]; then
                    if [ "$newest_date" == "" ]; then
                        newest_date="$current_date_seconds"
                    else
                        if [ "$current_date_seconds" -gt "$newest_date" ]; then
                            newest_date="$current_date_seconds"
                        fi
                    fi
                fi
                current_day=
                current_hour_minute= 
                current_date_seconds=              
            else
                date_parse=$( echo $thing | date -d "$thing" +%Y-%m-%d 2> /dev/null )
                if [ "$date_parse" != "" ]; then
                    current_day=$date_parse
                fi
            fi

        done
        
        date  --date @$newest_date +%Y-%m-%d_%H.%M.%S
        
    fi

}



function purge() {
 
    # eliminate redundant checksums
    
    # satisfy window requirements


    pushd $backups_folder >/dev/null

    for backup_file in `ls`; do
        if [ "$(validate_backupfile $backup_file)" == "VALID" ]; then
            get_date_from_path $backup_file
        fi
    done

    popd > /dev/null


}


if [ "$1" == "auto" ]; then
    backup auto
elif [ "$1" == "restore" ]; then
    restore $2
elif [ "$1" == "validate" ]; then
    validate_backupfile $2
elif [ "$1" == "purge" ]; then
    purge
else
    backup
fi
