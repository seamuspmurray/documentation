Param(
  [string]$cluster  
)
Import-Module  SSH-Sessions


#Start-Transcript -path C:\ssh-fail2\logs\transcript.txt -append


##set dubug level

#$debug=1
#f ( $debug -eq 1 ) {
#               # Debug log file
#                $deboutfile=$scriptdir+"\outputlog."+$siteid+".log"
#               start-transcript -path $deboutfile -force
#               # Shows a trace of each line being run with variables as variables
#               set-psdebug -trace 1
#
#}

if ( $cluster -eq 'Indexer' -Or  $cluster -eq 'Header' -Or $cluster -eq 'ForwarderA' -Or $cluster -eq 'ForwarderB')
{

}
else{
Write-Host "you must specifiy the cluster to test using an argument"
break
}

##     IP Function           Hostname        Role    
Switch ($cluster)
{
ForwarderA {
$server_P1='192.168.208.151' #a	Splunk Forwarder	ESSFW2032001TS	MELPM-EMS-SPLUNK-5
$server_P2='192.168.208.152' #a	Splunk Forwarder	ESSFW2032002TS	MELPM-EMS-SPLUNK-6
$server_VIP='192.168.208.153' #a Splunk Forwarder VIP
$server_DR='192.168.207.232' #a	Splunk Forwarder	ESSFW2021001TS	SYD-EMS-SPLUNK-3
}
ForwarderB{
$server_P1='192.168.208.155' #b	Splunk Forwarder	ESSFW2032003TS	MELPM-EMS-SPLUNK-7
$server_P2='192.168.208.156' #b	Splunk Forwarder	ESSFW2032004TS	MELPM-EMS-SPLUNK-8
$server_VIP='192.168.208.157' #b Splunk Forwarder VIP	
$server_DR='192.168.207.233' #b	Splunk Forwarder	ESSFW2021002TS	SYD-EMS-SPLUNK-4
}
Indexer{
$server_P1='192.168.208.177' #c	Splunk Indexer	ESSIX2032001TS	MELPM-EMS-SPLUNK-1
$server_P2='192.168.208.178' #c	Splunk Indexer	ESSIX2032002TS	MELPM-EMS-SPLUNK-2
$server_VIP='192.168.208.176' #c Splunk Indexer VIP
$server_DR='192.168.207.217' #c	Splunk Indexer	ESSIX2021001TS	SYD-EMS-SPLUNK-1
}
Header{
$server_P1='192.168.208.185' #d	Splunk S/Head/Index		ESSHD2032001TS	MELPM-EMS-SPLUNK-3
$server_P2='192.168.208.186' #d 	Splunk S/Head/Index		ESSHD2032002TS	MELPM-EMS-SPLUNK-4
$server_VIP='192.168.208.184' #d Splunk S/Head/Index VIP
$server_DR='192.168.207.218' #d	Splunk S/Head-Index	ESSHD2021001TS	SYD-EMS-SPLUNK-2
}
}

##set log file to local directory  eg..2013-03-12_1151_192.168.208.151_splunkfail
$Logfile = "c:\ssh-fail2\logs\$(get-date -uformat %Y-%m-%d_%H%M)"+"_$server_P1"+"_splunkfail.log"

#Write_Host $Logfile
#LogWrite  $env:PSModulePath
Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}

$stamped  = "$(Get-Date)" + " starting script "
LogWrite $stamped





#Remote Scripts executed on the linux servers but called from this script
#You must specify the argument "Up" case sensitive for this test to succeed 
#If you want to simulate this test failing just change the argument
$SplunkPrimaryTest='/home/ntf-failover-user/splunkfailover0.1/primary-test.sh Up'

#Specifiy which server the DR should test by assigning a single argument....P1 P2 or VIP
#the Various IPs are stored both locally in this file and in   SplunkConfirmPriDown.sh on the respective DR servers
#If you want to simulate this test failing just change the argument to something else
$SplunkConfirmPriDown='/home/ntf-failover-user/splunkfailover0.1/primary-confirm-fail.sh VIP'

#this command needs to execute the start up script via sudo this either requires a tty which "SSH-Sessions" doesn't provide or..editing sudo to disable the requiretty in /etc/sudoers
#This script varies slightly between the Splunk Forwarders and the Splunk Indexers
#On the Splunk indexers the NetApp mirrored lun's need to be broken and mounted this is handled by the..
#Break-n-Mount.sh script called from within the SplunkMountStart.sh executed from the DR servers
$SplunkMountStart='/home/ntf-failover-user/splunkfailover0.1/initiate-dr.sh Start' 

#called from within $SplunkMountStart on the Indexer DR servers
#$Break-n-Mount='/home/ntf-failover-user/splunkfailover0.1/break-snap-mirror.sh RESYNC'





while("forever")
{
    New-SshSession -ComputerName $server_P1 -Username 'ntf-failover-user'  -KeyFile 'C:\ssh-fail2\id_rsa' # | out-null 
    New-SshSession -ComputerName $server_DR -Username 'ntf-failover-user'  -KeyFile 'C:\ssh-fail2\id_rsa' # | out-null 
    
	
try
{
 #Write_Host "Testing SplunkPrimaryTest on $server_P1 1st loop"
 $stamped = "$(Get-Date)" + " Testing SplunkPrimaryTest on $server_P1 1st loop"
 LogWrite  $stamped
 $CmdOutput1 = Invoke-SshCommand -ComputerName $server_P1 -Command $SplunkPrimaryTest -Quiet
}
catch [Exception]
{ 
  $CmdOutput1 = "SSH_SESSION_FAILED" 
  #Write_Host"ERROR: $CmdOutput1 during 1st loop" -foregroundcolor white -backgroundcolor red
  $stamped  = "$(Get-Date)" + " ERROR: $CmdOutput1 during 1st loop"
  LogWrite $stamped
}
   

    #Check Primary Server for status
    if ( $CmdOutput1 -ne 'Primary_App_Is_Up' ) { 
        #Write_Host "ERROR: Primary Failure Detected"
		#Write_Host "Waiting 10 seconds before retrying"
		$stamped =  "$(Get-Date)" + " ERROR: Check Primary did not return Primary_App_Is_Up   Waiting 10 seconds before retrying"		
        LogWrite $stamped
		sleep 10
		
        
        try
	   {
	       #Write_Host "Testing SplunkPrimaryTest on $server_P1 2nd loop"
           $CmdOutput1 = Invoke-SshCommand -ComputerName $server_P1 -Command $SplunkPrimaryTest -Quiet
	   }
	   catch [Exception]
           {
		     $CmdOutput1 = "SSH_SESSION_FAILED"
			 #Write_Host"$CmdOutput1 during 2nd loop" -foregroundcolor white -backgroundcolor red
             $stamped =  "$(Get-Date)" + " $CmdOutput1 during 2nd loop"
			 LogWrite $stamped
	   }
   
              	#Check Primary Server for status after a previous failure
              	if ( $CmdOutput1 -ne 'Primary_App_Is_Up' ) { 
              	#Write_Host "ERROR: Primary Failure Detected 2 times"
				$stamped =  "$(Get-Date)" + " ERROR: Check Primary did not return Primary_App_Is_Up after 2 tries"
                LogWrite $stamped

		   try
	   	   {
           	   $CmdOutput2 = Invoke-SshCommand -ComputerName $server3 -Command $SplunkPrimaryTest -Quiet
	   	   }
	   	   catch [Exception]
           	   {
           	   #Write_Host "ERROR:ssh session to $server_P1 has failed. Unable to execute SplunkPrimaryTest"
			   $stamped =  "$(Get-Date)" + " ERROR:ssh session to $server_P1 has failed. Unable to execute SplunkPrimaryTest"
			   LogWrite $stamped
	   	   }
       
                    #If this host fails 2 time to determine if Primary_App_Is_Up, then ask DR server to also run the check          
                    if ( $CmdOutput2 -ne 'Primary_App_Is_Up' ) {     
                    #Write_Host "ERROR: DR Server $server3 is also reporting Primary Failure....... Need to Initate DR"
                    $stamped =  "$(Get-Date)" + " ERROR: DR Server is also reporting Primary Failure....... Need to Initate DR"
					LogWrite $stamped
        

		        try
			{
		 	$CmdOutput3 = Invoke-SshCommand -ComputerName $server_DR -Command $SplunkMountStart  -Quiet
			}
			catch [Exception]
			{
			$CmdOutput3 = "SSH_SESSION_FAILED"
  			#Write_Host "ERROR:ssh session to $server_DR has failed. Unable to execute SplunkMountStart"
			$stamped =  "$(Get-Date)" + " ERROR:ssh session to $server_DR has failed. Unable to execute SplunkMountStart"
			LogWrite $stamped
			
                        }     		            
                
            
                if ( $CmdOutput3 -ne 'App_Started' ) {     
                #Write_Host "ERROR: DR server $server_DR Failed to start the App"
				$stamped =  "$(Get-Date)" + " ERROR: DR server $server_DR Failed to start the App"
				LogWrite $stamped
                
        
                }
                else {
                   #Write_Host "DR server $server_DR has started the App"
				   $stamped =  "$(Get-Date)" + " DR server $server_DR has started the App"
				   LogWrite $stamped
				   $stamped =  "$(Get-Date)" + " Nothing else to do...Failover scipt self terminating"
				   LogWrite $stamped
				   break
                }  
            
        }
        else {
            #Write_Host "DR server $server_DR is reporting Primary $server_P1 is OK: Nothing To Do"
			#Write_Host "Assuming the link between me and the Primary server has failed"
			$stamped =  "$(Get-Date)" + " Assuming the link between me and the Primary server has failed"
			LogWrite $stamped
        } 
    }
              else {
                #Write_Host "Primary server $server_P1 is OK: Nothing To Do             2nd test"   
				$stamped =  "$(Get-Date)" + " Primary server $server_P1 is OK: Nothing To Do             2nd test" 
				LogWrite $stamped
                   } 
	}
    else {
        #Write_Host "Primary server $server_P1 is OK: Nothing To Do             1st test"   
		$stamped =  "$(Get-Date)" + " Primary server $server_P1 is OK: Nothing To Do             1st test" 
		LogWrite $stamped
    } 

    sleep 5

}

Remove-SshSession -RemoveAll

#Stop-Transcript