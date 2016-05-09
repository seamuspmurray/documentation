#!/bin/bash

function usage ()
{
	echo "usage: $0 name start end [width] [fence]" 
	echo "name:  base name for cluster and nodes"
	echo "start: first nodeid number"
	echo "end:   last nodeid number"
	echo "width: zero pad nodeid in node names to this width"
	echo "fence: fence device name added for each node"
	exit 1
}

if [ $# -lt 3 -o $# -gt 5 ]; then
	usage
fi

NAME=$1
START=$2
END=$3

if [ $# -gt 3 ]
then
	W=$4
fi

if [ $# -gt 4 ]
then
	F=$5
fi

echo '<?xml version="1.0"?>'
echo '<cluster name="'${NAME}'-cluster" config_version="1">'
echo '<clusternodes>'

i=${START}
while [ $i -le $END ]
do
	printf -v zi "%0${W}d" $i

	if [ "$F" = "" ]; then
		echo '<clusternode name="'${NAME}'-'$zi'" nodeid="'$i'"/>'
	else
		echo '<clusternode name="'${NAME}'-'$zi'" nodeid="'$i'">'
		echo '        <fence>'
		echo '        <method name="1">'
		echo '        <device name="'${F}'"/>'
		echo '        </method>'
		echo '        </fence>'
		echo '</clusternode>'
	fi

	i=`expr $i + 1`
done

echo '</clusternodes>'


if [ "$F" != "" ]; then
	echo ''
	echo '<fencedevices>'
	echo '<fencedevice name="'${F}'" agent="fence_'${F}'"/>'
	echo '</fencedevices>'
fi

echo '</cluster>'

