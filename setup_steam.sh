#!/bin/bash

pushd ~ > /dev/null

steamcmd_directory=steamcmd

if [ ! -d "$steamcmd_directory" ]; then
    
   echo Making directory...
   mkdir $steamcmd_directory > /dev/null

else

   echo $steamcmd_directory exists, quitting...
   exit

fi


echo Getting installer...
tarball_url=http://media.steampowered.com/installer/steamcmd_linux.tar.gz
tempdir="/tmp/alexs_temp_$RANDOM"
mkdir $tempdir > /dev/null
cd $tempdir > /dev/null

wget -q $tarball_url
tar xvfz steamcmd_linux.tar.gz -C ~/steamcmd > /dev/null
rm -rf $tempdir > /dev/null

echo Updating aptitude

sudo apt-get -q=2 update > /dev/null
sudo apt-get -q=2 upgrade > /dev/null
echo Installing dependencies

sudo apt-get -q=2 install lib32gcc1 > /dev/null

popd > /dev/null

echo Done. Please cd to ~/steamcmd and run ./steamcmd.sh to finish setup


