#!/bin/bash


function task_exists() {
    taskfound=false
    if [ "$1" != "" ]; then
        task=$(ps aux | grep $1 | awk '{print $2}')
        if [ "$task" != "" ]; then
            taskfound=true
        fi
    fi
    echo $taskfound
}

function get_tasks() {
    ps aux | grep 'starbound_server' | grep -v grep | awk '{print $2}'
}


function kill_tasks() {
    if [ "$1" == "stern" ]; then
        #TERM
        killsignal=15
    elif [ "$1" == "nasty" ]; then
        #KILL
        killsignal=9
    else
        #INT
        killsignal=2
    fi

    for task in `get_tasks`; do
        if [ "$(task_exists $task)" == "true" ]; then    
            kill -$killsignal $task > /dev/null
            sleep 1
        fi
    done
}


function cascade_kills(){
    tasks_to_kill=$(get_tasks)

    hard_kills=0
    hard_kill_limit=5
    turn=0
    wait_time=0
    while [ "$(get_tasks)" != "" ]; do
        sleep $wait_time
        if [ "$(get_tasks)" != "" ]; then

		if [ "$turn" == "0" ]; then
		    echo "Sir?"
                    kill_tasks cordial

		    wait_time=10
		elif [ "$turn" == "1" ]; then
		    echo "Sir..."
                    kill_tasks stern
		    wait_time=10
		else
                   
		    echo "Sir."
                    kill_tasks nasty
		    hard_kills=$( echo "$hard_kills + 1" | bc )
		    wait_time=5
		fi

		if [ "$turn" -lt 2 ]; then
		    turn=$( echo "$turn + 1" | bc )
		fi 
                if [ "$hard_kills" -ge "$hard_kill_limit" ]; then
                    echo "Sir, we've called the police."
                    exit 1
                fi
        fi

    done

}

if [ "$1" == "cordial" ]; then
    kill_tasks cordial
elif [ "$1" == "nasty" ]; then
    kill_tasks nasty
elif [ "$1" == "stern" ]; then
    kill_tasks stern
else
    cascade_kills
fi


