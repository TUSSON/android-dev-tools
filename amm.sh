#!/bin/bash

KILL_DEPENDS_PS=false

if [[ $# == 1 ]]; then
    if [[ $1 == '-k' ]]; then
        KILL_DEPENDS_PS=true
    else
        echo "amm [-k] [path]"
        echo "  -k: kill process depend on update files"
        return
    fi
fi

make_cmd="mm"
for arg in $* ; do
    if [[ -d $arg ]]; then
        make_cmd="mmm"
        break
    fi
done

function getLastMakeId
{
    tail -1 $NINJA_LOG | awk '{print $3}'
}

function getFileLines
{
    wc $NINJA_LOG | awk '{print $1}'
}

ATOP_DIR=$(getAndroidTop)
device_version=`grep -o 'PLATFORM_VERSION :=.*' $ATOP_DIR/build/core/version_defaults.mk | cut -c 21-23`

if [[ $device_version > 6.9 ]]; then
    NINJA_LOG=$ATOP_DIR/out/.ninja_log
    LAST_FILE_LINES=$(getFileLines)
fi

LAST_MM_LOGS=/tmp/.last_amm_log
$make_cmd $* | tee $LAST_MM_LOGS

if [[ $device_version < 7.0 ]]; then
    update_files=`grep -o "Install:[^\"]*" $LAST_MM_LOGS | cut -d ' ' -f 2` 
else
    FILE_LINES=$(getFileLines)
    lines="$(($FILE_LINES-$LAST_FILE_LINES))"
    #echo "update lines:" $lines
    update_files=`tail -$lines $NINJA_LOG | ag 'out/target/product/[^/]*/(?:system|vendor)' | awk '{print $4}'`
fi
apush $update_files

LSOF_DATA_FILE=/tmp/.mm_push_lsof_data.txt
adb shell lsof > $LSOF_DATA_FILE

declare -A pidList=()
index=1

for i in $(echo $update_files); do
    pushPath=${i#*out/target/product/*/}
    pids=$(cat $LSOF_DATA_FILE | ag $pushPath | awk '{print $2}')
    for pid in `echo $pids`; do
        echo "pid $pid depend on $pushPath"
        if [[ $KILL_DEPENDS_PS == true ]]; then
            new_pid=true
            for p in $pidList; do
                if [[ $p == $pid ]]; then
                    new_pid=false
                fi
            done
            if [[ $new_pid == true ]]; then
                pidList[$index]=$pid
                ((index+=1))
            fi
        fi
    done
done

for pid in $pidList; do
    echo "adb shell kill $pid"
    adb shell kill $pid
done
