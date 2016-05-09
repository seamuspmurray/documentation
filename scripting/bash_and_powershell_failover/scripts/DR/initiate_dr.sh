#!/bin/bash

echo  >> /home/ntf-failover-user/splunkfailover0.1/startlog
echo `date`  start >> /home/ntf-failover-user/splunkfailover0.1/startlog

if [ "$1" = "Start" ] ;
   then
  # Start_App="App_Started"

       echo `date` " " $0" " $1 >> /home/ntf-failover-user/splunkfailover0.1/startlog
        /usr/bin/sudo /etc/init.d/splunk-heavy restart &> /home/ntf-failover-user/splunkfailover0.1/startlog
        echo "sudo /etc/init.d/splunk-heavy restart" >> /home/ntf-failover-user/splunkfailover0.1/startlog

        if  [[ $? = "0"  ]]
                then
                 Start_App="App_Started"
                 echo $Start_App
                else
                 echo $0 Failed to restart app
                 echo $Start_App

        fi
   else
   echo `date` Usage $0 Start >> /home/ntf-failover-user/splunkfailover0.1/startlog
fi

echo `date`  finsihed >> /home/ntf-failover-user/splunkfailover0.1/startlog

#/usr/bin/sudo /etc/init.d/splunk-heavy restart
