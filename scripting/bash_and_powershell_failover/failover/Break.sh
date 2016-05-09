#!/bin/bash

 

function GETLUN_STATUS {
     #values Snapmirrored Quiesced Broken-off
     #ssh  -a svc-local-splunk@192.168.212.48 'snapmirror status ESSHD2032001TS_data_1'
     ssh  -a localhost '/home/guess/fakecommand.sh'
}

 

function SETLUN_QUIESCE {
        ssh  -a svc-local-splunk@192.168.212.48 'snapmirror quiesce ESSHD2032001TS_data_1'
        GETLUN_STATUS
}

 

function SETLUN_BREAK {
        ssh  -a svc-local-splunk@192.168.212.48 'snapmirror break ESSHD2032001TS_data_1'
}

 

function LUN_SHOW {
        ssh  -a svc-local-splunk@192.168.212.48 'lun show'
}

 

function IGROUP_CREATE {
        ssh  -a svc-local-splunk@192.168.212.48 'igroup create -f -t linux ESSHD2032001TS 20:00:00:25:B5:D1:03:01 20:00:00:25:B5:D1:03:02'
}

 

function LUN_MAP {
        ssh  -a svc-local-splunk@192.168.212.48 'lun map /vol/ESSHD2032001TS_data_1/ESSHD2032001TS_data_1.lun ESSHD2032001TS'
}

 

function LUN_UNMAP {
        ssh  -a svc-local-splunk@192.168.212.48 'lun unmap /vol/ESSHD2032001TS_data_1/ESSHD2032001TS_data_1.lun ESSHD2032001TS'
}

 

function IGROUP_SHOW {
        ssh  -a svc-local-splunk@192.168.212.48 'igroup show'
}

 

function IGROUP_DESTROY {
        ssh  -a svc-local-splunk@192.168.212.48 'igroup destroy ESSHD2032001TS'
}

 

function MIRROR_RESYNC {
        ssh  -a svc-local-splunk@192.168.212.48 'snapmirror resync  ESSHD2032001TS_data_1'
}

function STORAGERESCAN {
        sudo /opt/storage-rescan
}


function MULTIPATH {
        sudo /sbin/multipath -ll
}

 

function DF {
        df -h
}

 

function MOUNT {
        sudo /bin/mount /dev/mapper/mpath1p1 /tmp/splunk/
}

 

function UNMOUNT {
        sudo /bin/umount /dev/mapper/mpath1p1 /tmp/splunk/
}

 

function QUIT {
        exit
}

 

 

 

if [ "$1" = "BREAK" ]  #Start of AutoBreak sequence
 then


GETLUN_STATUS |grep STSSP | grep Quiesced && STATE="Snapmirrored"
GETLUN_STATUS |grep STSSP | grep Quiesced && STATE="Quiesced"
GETLUN_STATUS |grep STSSP | grep Quiesced && STATE="Broken-off"

echo Auto break
echo Running SETLUN_QUIESCE

#GETLUN_STATUS |grep STSSP | grep Quiesced && STATE="Quiesced"
 	until [[ "$STATE" = "Quiesced" ]]
 		do
         	GETLUN_STATUS |grep STSSP | grep Quiesced && STATE="Quiesced"
  		echo "Running GETLUN_STATUS  -- last status was $STATE" && sleep 1
done

echo Auto break
echo Running SETLUN_BREAK
GETLUN_STATUS |grep STSSP | grep "Broken-off" && STATE="Broken-off"
 	until [[ "$STATE" = "Broken-off" ]]
 		do
  		echo "Running GETLUN_STATUS -- last status was $STATE" && sleep 1
         	GETLUN_STATUS |grep STSSP | grep "Broken-off" && STATE="Broken-off"
	done
		echo running IGROUP_CREATE
		echo running LUN_MAP
		echo running STORAGERESCAN 
		echo running Confirm that the Lun is now visable to the DR host
		echo running MOUNT
		echo running DF 


elif [ "$1" = "RESYNC" ]   #Start of Auto resync sequence
 then
	echo auto resync


echo UNMOUNT
echo LUN_UNMAP
echo IGROUP_DESTROY
echo MIRROR_RESYNC #; this requires an interactive "yes" response
ssh localhost '/home/guess/prompt.sh'
echo STORAGERESCAN



elif [[ "$1" = "MENU" || "$1" = "menu" ]]
then 

echo "What do you want to do with the storage"

select FUNCTION in GETLUN_STATUS SETLUN_QUIESCE SETLUN_BREAK LUN_SHOW IGROUP_CREATE LUN_MAP LUN_UNMAP IGROUP_SHOW IGROUP_DESTROY MIRROR_RESYNC STORAGERESCAN MULTIPATH DF MOUNT UNMOUNT QUIT

do
     $FUNCTION
done

 

# REBUILD MENU AFTER ADDING OR REMOVING FUCTIONS
# cat Break.sh | grep function | awk '{ printf "%s ", $2 }'

elif [[ "$1" = "HELP" || "$1" = "help" ]]
then 
cat <<EOF

This script can be used in 4 different modes.....

HELP = display this message

BREAK = automatically break the mirror
        map the lun to this host and
        mount the lun

RESYNC = automatically unmount the lun


MENU = Provides a menu of all the previously prepared commands
       See the text below for details on the various steps
  

All the necessary commands have been placed into functions within this script $0
you can rerun this script in MENU mode and step through the various functions until you achieved the desired result.


Break the mirror and mount the Lun on DR..

(1) GETLUN_STATUS ; Confirm that the Lun status is "Snapmirrored" before proceeding
(2) SETLUN_QUIESCE
 (2a)  wait until the Lun status is "Quiesced"
(3) SETLUN_BREAK
 (3a) wait until the lun status is "Broken-off"
(4) IGROUP_CREATE
(5) LUN_MAP
(6) STORAGERESCAN
 (6a)Confirm that the Lun is now visible to the DR host
(7) MOUNT
(8) DF ; confirm that the lun is mounted



Resync Primary to DR  after umounting the Lun on DR..
 
(1) stop the application and ensure that there are no open files on the partition
(2) UNMOUNT
(3) LUN_UNMAP
(4) IGROUP_DESTROY
(5) MIRROR_RESYNC ; this requires an interactive "yes" response
(6) STORAGERESCAN ; this is optional but it is best to clean things up

EOF


else
echo "Usage: $0 BREAK,RESYNC,MENU or HELP "
exit 1
fi

 

