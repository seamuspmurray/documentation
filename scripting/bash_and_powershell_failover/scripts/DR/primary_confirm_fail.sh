#!/bin/bash
# 192.168.208.151 192.168.208.152 192.168.208.153


VIP=192.168.208.153
P1=192.168.208.151
P2=192.168.208.152

if [[ "$1" = "VIP" ]]; then TEST="$VIP"
elif [[ "$1" = "P1" ]]; then TEST="$P1"
elif [[ "$1" = "P2" ]]; then TEST="$P2"

else
echo "Usage: you much define which node to test {VIP,P1,P2}"
exit 0
fi

        if [[ `ssh $TEST -q -C /home/ntf-failover-user/splunkfailover0.1/primary-test.sh Up` = "Primary_App_Is_Up"  ]]  ; then
                echo Primary_App_Is_Up
        else
                echo test-failed
        fi



