#!/bin/bash
function GETLUN_STATUS {
     #values Snapmirrored Quiesced Broken-off
     ssh  -a localhost '/home/guess/fakecommand.sh'
}

STATE="unknown"
until [[ "$STATE" = "Broken-off" ]]
do
echo $STATE
sleep 5


STATUS=`GETLUN_STATUS`
echo $STATUS | grep Snapmirrored && STATE="Snapmirrored"
echo $STATUS | grep Quiesced && STATE="Quiesced"
echo $STATUS | grep Broken-off && STATE="Broken-off"
done
