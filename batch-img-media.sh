#!/bin/bash

device=$1

if test -z "$device"
then
    echo "MISSING device (argument 1)"
    exit 1
fi

infomedia=true

while true
do
    LABEL=''
    DEVNAME=''
    BLOCK_SIZE=''

    eval "$(blkid -o export $device)"

    if test -z "$DEVNAME"
    then
        if $infomedia
        then
            echo "INFO: insert media on $device, or hit CTRL+C"
            infomedia=false
        fi

        sleep 9s
        continue
    fi

    if test -z "$BLOCK_SIZE" -o $BLOCK_SIZE -eq 0
    then
        echo "FAIL: invalid BLOCK_SIZE='$BLOCK_SIZE'"
        eject $device
        continue
    fi

    if test -z "$LABEL"
    then
        LABEL='NONAME'
        echo "WARN: $DEVNAME without label, using: $LABEL"
    fi

    isofn="${LABEL,,}.iso"

    # adiciona um sufixo numerado caso já exista o arquivo .iso
    i=0

    while test -f "$isofn"
    do
        i=$((i+1))
        isofn="${LABEL,,}-$i.iso"
    done

    # cria a imagem (o arquivo .iso)
    dd if=$device of="$isofn" bs=$BLOCK_SIZE status=progress

    eject $device

    echo "DONE: '$LABEL' -> '$isofn' (bs=$BLOCK_SIZE)"

    infomedia=true
done
