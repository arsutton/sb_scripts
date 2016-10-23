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

echo Getting rid of any mods that are no longer in the collection

mod_folder=/home/steam/Steam/steamapps/workshop/content/$STARBOUND_GAME_ID

for this_mod in `ls $mod_folder`; do

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
        pushd $mod_folder > /dev/null
        rm -rf $this_mod > /dev/null
        popd > /dev/null
    fi
    
done


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

./steamcmd.sh +login $username +app_update $STARBOUND_GAME_ID $workshop_download_string +quit


popd > /dev/null

#Copy the mods into the actual "mods" folder, being sure to murder the old files

echo Removing extant mod files...
pushd /home/steam/Steam/steamapps/common/Starbound/mods/ > /dev/null
rm -rf ./*
echo Installing latest mod files...
pushd /home/steam/Steam/steamapps/workshop/content/211820/ > /dev/null
cp -r ./* /home/steam/Steam/steamapps/common/Starbound/mods/
popd > /dev/null
popd > /dev/null

# CLEANUP

popd > /dev/null
rm -rf $tempdir > /dev/null
