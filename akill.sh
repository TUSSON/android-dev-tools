#!/bin/bash

if [[ $# == 0 ]]; then
    key='.'
else
    key=$1
fi

TMP_PS_FILE="/tmp/.adb_shell_ps_result.txt"
TMP_PS_S_FILES="/tmp/.adb_shell_ps_s_result.txt"
adb shell ps -A > $TMP_PS_FILE || adb shell ps > $TMP_PS_FILE
cat $TMP_PS_FILE | grep $key | fzf --multi -1 -0 > $TMP_PS_S_FILES || exit 0

cat $TMP_PS_S_FILES
selected_pids=`cat $TMP_PS_S_FILES|  awk '{print $2}'`

for pid in $selected_pids; do
    echo -n "adb shell kill $pid "
    adb shell kill $pid && echo "success"
done
