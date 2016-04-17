#!/bin/sh

DB=procmon

curl -G http://localhost:8086/query --data-urlencode "q=CREATE DATABASE IF NOT EXISTS $DB"

while :
do
	for proc in $(iotop -P -n1 -b -qqq | awk '{printf "%s,%s,%s,%s,%s,%s\n",$3,$4,$6,$8,$10,$12}')
	do
		USER=$(printf $proc | cut -f1 -d,)
		DISK_READ=$(printf $proc | cut -f2 -d,)
		DISK_WRITE=$(printf $proc | cut -f3 -d,)
		SWAPIN=$(printf $proc | cut -f4 -d,)
		IO=$(printf $proc | cut -f5 -d,)
		CMD=$(printf $proc | cut -f6 -d, | sed 's/\[//g' | sed 's/\]//g')

		if [ ! -z "$BATCH" ]; then
			BATCH=$(printf "%s\ndisk_read,user=%s,cmd=%s value=%f" "$BATCH" "$USER" "$CMD" $DISK_READ)
			BATCH=$(printf "%s\ndisk_write,user=%s,cmd=%s value=%f" "$BATCH" "$USER" "$CMD" $DISK_WRITE)
			BATCH=$(printf "%s\nswapin,user=%s,cmd=%s value=%f" "$BATCH" "$USER" "$CMD" $SWAPIN)
			BATCH=$(printf "%s\nio,user=%s,cmd=%s value=%f" "$BATCH" "$USER" "$CMD" $IO)
		else
			BATCH=$(printf "disk_read,user=%s,cmd=%s value=%f" "$USER" "$CMD" $DISK_READ)
			BATCH=$(printf "disk_write,user=%s,cmd=%s value=%f" "$USER" "$CMD" $DISK_WRITE)
			BATCH=$(printf "swapin,user=%s,cmd=%s value=%f" "$USER" "$CMD" $SWAPIN)
			BATCH=$(printf "io,user=%s,cmd=%s value=%f" "$USER" "$CMD" $IO)
		fi

	done
	curl -i -XPOST "http://localhost:8086/write?db=$DB" --data-binary "$BATCH"
	BATCH=""
	sleep 5
done
