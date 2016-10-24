#!/bin/bash

# USER SELECTION
echo
if [ "$1" == "alex" ]; then
    echo Update running as Alex
    username=aurarier
elif [ "$1" == "vinnie" ]; then
    echo Update running as Vinnie
    username=almightyanus
else
    echo Update running anonymously
    username=anonymous
fi
echo

# CONSTANTS

STARBOUND_GAME_ID=211820
MOD_COLLECTION_ID=756472403


# TEMPDIR CREATION

tempdir="/tmp/sb_and_mods_update_$RANDOM"

mkdir $tempdir > /dev/null
pushd $tempdir > /dev/null


# COLLECTING MODS

echo Getting list of mods in collection $MOD_COLLECTION_ID
collection_url=http://steamcommunity.com/sharedfiles/filedetails/?id=$MOD_COLLECTION_ID

wget -q $collection_url

mod_list=`cat *index* | awk -F "sharedfile_" '{print $2}' | awk -F "\"id\":\"" '{print $2}' | awk -F "\"" '{print $1}'`

rm -f * > /dev/null


# GETTING RID OF OLD MODS

mod_folder=/home/steam/Steam/steamapps/workshop/content/$STARBOUND_GAME_ID
if [ -d "$mod_folder" ]; then
    echo Getting rid of any mods that are no longer in the collection
    mod_folder=/home/steam/Steam/steamapps/workshop/content/$STARBOUND_GAME_ID
    pushd $mod_folder > /dev/null
    for this_mod in `ls -d */ 2> /dev/null`; do
        this_mod=$( echo $this_mod | awk -F '/' '{print $1}' )
        mod_belongs=false
        for desired_mod in `echo $mod_list`; do
            if [ "$desired_mod" == "$this_mod" ]; then
                mod_belongs=true
            fi
        done

        if [ "$mod_belongs" == 'true' ]; then
            touch /dev/null
        else
            echo Removing $this_mod
            rm -rf $this_mod > /dev/null
        fi
        
    done
    popd > /dev/null
fi

# UPDATING STARBOUND AND MODS

pushd /home/steam/steamcmd > /dev/null

echo
echo UPDATING GAME
echo
 
#./steamcmd.sh +login $username +app_update $STARBOUND_GAME_ID +quit

for mod_id in `echo $mod_list`; do

    #echo
    #echo UPDATING MOD ID $mod_id
    #echo 

    workshop_download_string="$workshop_download_string +workshop_download_item $STARBOUND_GAME_ID $mod_id"
    #./steamcmd.sh +login $username +workshop_download_item $STARBOUND_GAME_ID $mod_id +quit
done

./steamcmd.sh +login $username +app_update $STARBOUND_GAME_ID validate $workshop_download_string +quit


popd > /dev/null

#Copy the mods into the actual "mods" folder, being sure to murder the old files

echo
echo COPYING MODS INTO DIRECTORY
echo

destination_folder=/home/steam/Steam/steamapps/common/Starbound/mods/

pushd $destination_folder > /dev/null
rm *.pak 2> /dev/null
popd > /dev/null
pushd $mod_folder > /dev/null
for mod_id in `ls -d */ 2> /dev/null`; do
    mod_id=$( echo $mod_id | awk -F '/' '{print $1}')
    destination_path=$destination_folder$mod_id\.pak
    source_path=$mod_id/contents.pak
    
    if [ -f "$source_path" ]; then
        if [ -f "$destination_path" ]; then
            echo KILLIN!
            rm $destination_path > /dev/null
        fi
        cp $source_path $destination_path > /dev/null
    fi  
done

chown -R steam:steam * 2> /dev/null

popd > /dev/null

# CLEANUP

popd > /dev/null
rm -rf $tempdir > /dev/null
