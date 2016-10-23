#!/bin/bash


case "$1" in
  start)
        if [ "$start_is_running" != "" ]; then
		echo "Starbound Server is already starting. I perish."
        else
		echo "Initializing Starbound Server..."
		export start_is_running=true
                if [ "$(pgrep starbound_)" == "" ]; then 
			touch /dev/null
		else 
			echo "Starbound Server appears to be already running"
			exit 0
		fi
		echo "Updating Starbound Server..."
		su steam -c '/home/steam/utilities/update_sb_and_mods.sh alex'
		echo "Launching Starbound Server..."
                pushd /home/steam/Steam/steamapps/common/Starbound/linux > /dev/null
		su steam -c 'screen -d -m "./starbound_server"'
		popd > /dev/null
		export start_is_running=
		echo "Starbound Server Launched"
        fi
		;;
  stop)
	if [ "$(pgrep starbound_)" != "" ]; then
		echo "Killing Starbound Server process(es)"
		/home/steam/utilities/shutdown_server.sh
		echo "Starbound Server has stopped"
	else 
		echo "Starbound Server appears not to be running anyway"
	fi
	;;
  restart)
	echo "Restarting Starbound Server. Going offline..."
	/etc/init.d/starbound stop
        /etc/init.d/starbound start
        ;;
  backup)
        /etc/init.d/starbound stop
        su steam -c '/home/steam/utilities/backup_sb.sh'
        /etc/init.d/starbound start
        ;;
  status)
	#if there are no pgrep results, it's not running
	if [ "$(pgrep starbound_)" == "" ]; then
		echo "Starbound Server appears not to be running"
	#otherwise gather information about the server process
	else
		#set some variables
		spid=$(pgrep starbound_)
		spid=($spid)
		spid_count=${#spid[@]}
		#if there is just one result, it is running on that PID
		if [ "$spid_count" == "1" ]; then
			echo "Starbound Server is running on PID $spid"
		#if there are multiple processes, list them and their names
		elif [ "$spid_count" -gt "1" ]; then
			echo "Something\'s gone wrong. Check these PIDs to see if one makes sense:"
			ps -ef | grep starbound
		else
			echo "Guys, I think I brokeded it. I'm leaving now. You fix it."
		fi
	fi
        ;;
  update)
	/etc/init.d/starbound restart
	;;
esac

exit 0



