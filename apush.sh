#!/bin/bash

if [[ $# == 0 ]]; then
    exit 1
elif [[ $# == 2 && `echo $2 | grep 'out/target/product'` == "" ]] ; then
    adb push $*
    exit 0
fi

function getAndroidTop
{
    local TOPFILE=build/core/envsetup.mk
    local T=$PWD
    while [ \( ! \( -f "$T/$TOPFILE" \) \) -a \( $T != "/" \) ]; do
        T=`dirname $T`
    done
    if [ -f "$T/$TOPFILE" ]; then
        echo $T
    fi
}

echo ""
echo "start push..."
for file in $* ; do
    fromPath=$file
    if [[ `echo $file | grep -o 'out/host'` ]] ; then
        continue    
    fi

    if [[ -f $fromPath ]] ; then
        fromPath=`realpath $fromPath`
    else 
        fromPath="$(getAndroidTop)/"`echo $fromPath | grep -o 'out/target/product/.*'`
    fi
    pushPath=${fromPath#*out/target/product/*/}
    if [[ `echo $pushPath | grep -o 'data/nativetest'` ]]; then
        pushPath="/system/bin/"`basename $pushPath`
    fi
    echo "-> $pushPath"
    adb push $fromPath $pushPath
done
