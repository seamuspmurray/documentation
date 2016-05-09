#!/bin/bash
#Script to log into the nodes and see who currently has the luns

Igroup_share=A_B
Igroup_P1=singleA
Igroup_P2=singleB

function Who_Has_The_LUNS {
   for Igroup in $Igroup_share $Igroup_P1 $Igroup_P2
     do	
        return=(`ssh -a localhost  'cat /home/guess/fence/"'$Igroup'"'`)
	echo $Igroup has ${#return[@]} luns
   done
}	

Who_Has_The_LUNS
