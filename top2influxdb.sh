#!/bin/sh

DB=procmon

curl -G http://localhost:8086/query --data-urlencode "q=CREATE DATABASE IF NOT EXISTS $DB"

while :
do
	for proc in $(top -n1 -b | tail -n+8 | awk '{printf "%s,%s,%s,%s,%s\n",$1,$2,$9,$10,$12}')
	do
		PID=$(printf $proc | cut -f1 -d,)
		USER=$(printf $proc | cut -f2 -d,)
		CPU=$(printf $proc | cut -f3 -d,)
		MEM=$(printf $proc | cut -f4 -d,)
		CMD=$(printf $proc | cut -f5 -d,)

		if [ ! -z "$BATCH" ]; then
			BATCH=$(printf "%s\ncpu,pid=%d,user=%s,cmd=%s value=%f" "$BATCH" $PID "$USER" "$CMD" $CPU)
			BATCH=$(printf "%s\nmem,pid=%d,user=%s,cmd=%s value=%f" "$BATCH" $PID "$USER" "$CMD" $MEM)
		else
			BATCH=$(printf "cpu,pid=%d,user=%s,cmd=%s value=%f" $PID "$USER" "$CMD" $CPU)
			BATCH=$(printf "mem,pid=%d,user=%s,cmd=%s value=%f" $PID "$USER" "$CMD" $MEM)
		fi

	done
	curl -i -XPOST "http://localhost:8086/write?db=$DB" --data-binary "$BATCH"
	BATCH=""
	sleep 5
done
