#!/bin/bash
echo "starting BREAK script" >> /home/ntf-failover-user/splunkfailover0.1/startlog


NETAPP_KEY="/home/ntf-failover-user/.ssh/netapp_id_rsa"

function GETLUN_STATUS {
     #values Snapmirrored Quiesced Broken-off
     ssh  -i $NETAPP_KEY -a svc-local-splunk@192.168.212.48 'snapmirror status ESSHD2032001TS_data_1'
     #ssh  -a localhost '/home/guess/fakecommand.sh'
}



function SETLUN_QUIESCE {
        ssh  -i $NETAPP_KEY -a svc-local-splunk@192.168.212.48 'snapmirror quiesce ESSHD2032001TS_data_1'
        GETLUN_STATUS
}



function SETLUN_BREAK {
        ssh  -i $NETAPP_KEY -a svc-local-splunk@192.168.212.48 'snapmirror break ESSHD2032001TS_data_1'
}



function LUN_SHOW {
        ssh -i $NETAPP_KEY -a svc-local-splunk@192.168.212.48 'lun show'
}



function IGROUP_CREATE {
        ssh -i $NETAPP_KEY -a svc-local-splunk@192.168.212.48 'igroup create -f -t linux ESSHD2032001TS 20:00:00:25:B5:D1:03:01 20:00:00:25:B5:D1:03:02'
}



function LUN_MAP {
        ssh -i $NETAPP_KEY -a svc-local-splunk@192.168.212.48 'lun map /vol/ESSHD2032001TS_data_1/ESSHD2032001TS_data_1.lun ESSHD2032001TS'
}



function LUN_UNMAP {
        ssh -i $NETAPP_KEY -a svc-local-splunk@192.168.212.48 'lun unmap /vol/ESSHD2032001TS_data_1/ESSHD2032001TS_data_1.lun ESSHD2032001TS'
}



function IGROUP_SHOW {
        ssh -i $NETAPP_KEY -a svc-local-splunk@192.168.212.48 'igroup show'
}



function IGROUP_DESTROY {
        ssh -i $NETAPP_KEY -a svc-local-splunk@192.168.212.48 'igroup destroy ESSHD2032001TS'
}



function MIRROR_RESYNC {
        ssh -i $NETAPP_KEY -a svc-local-splunk@192.168.212.48 'snapmirror resync  ESSHD2032001TS_data_1'
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
        sudo /bin/mount /dev/mapper/mpath1p1 /opt/splunk
}



function UNMOUNT {
        sudo /bin/umount /dev/mapper/mpath1p1
}



function QUIT {
        exit
}


function GREP_STATUS {
STATUS=`GETLUN_STATUS`
echo $STATUS | grep Snapmirrored && STATE="Snapmirrored"
echo $STATUS | grep Quiesced && STATE="Quiesced"
echo $STATUS | grep Broken-off && STATE="Broken-off"
}




if [ "$1" = "BREAK" ]  #Start of AutoBreak sequence
 then

echo Starting Auto break sequence 1 of 8
GREP_STATUS
if [[ "$STATE" != "Snapmirrored" ]]
        then
    echo Aucto Break sequence faile because lun state is currently $STATE
exit 1
fi

echo Running SETLUN_QUIESCE
SETLUN_QUIESCE
GREP_STATUS
        until [[ "$STATE" = "Quiesced" ]]
                do
                #GETLUN_STATUS |grep STSSP | grep Quiesced && STATE="Quiesced"
                GREP_STATUS
                echo "Running GETLUN_STATUS  -- last status was $STATE" && sleep 1
done
echo Starting Auto break sequence 2 of 8
echo Running SETLUN_BREAK
SETLUN_BREAK
GREP_STATUS
        until [[ "$STATE" = "Broken-off" ]]
                do
                echo "Running GETLUN_STATUS -- last status was $STATE" && sleep 1
                GREP_STATUS
        done
                echo running IGROUP_CREATE
                IGROUP_CREATE
                echo running LUN_MAP
                LUN_MAP
                echo running STORAGERESCAN
                STORAGERESCAN
                echo running MOUNT
                MOUNT
                echo running DF
                DF


elif [ "$1" = "RESYNC" ]   #Start of Auto resync sequence
 then
        echo auto resync


UNMOUNT # &&
sleep 5
LUN_UNMAP && IGROUP_DESTROY && MIRROR_RESYNC
#LUN_UNMAP
#IGROUP_DESTROY
#MIRROR_RESYNC #; this requires an interactive "yes" response
#ssh localhost '/home/guess/prompt.sh'
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
