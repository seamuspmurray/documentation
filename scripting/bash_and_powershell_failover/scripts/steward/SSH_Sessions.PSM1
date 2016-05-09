<#
.SYNOPSIS
A set of functions for dealing with SSH connections from PowerShell, using the SSH.NET
library found here on CodePlex: http://sshnet.codeplex.com/

See further documentation at:
http://www.powershelladmin.com/wiki/SSH_from_PowerShell_using_the_SSH.NET_library

Copyright (c) 2012, Svendsen Tech.
All rights reserved.
Author: Joakim Svendsen

.DESCRIPTION
See:
Get-Help New-SshSession
Get-Help Get-SshSession
Get-Help Invoke-SshCommand
Get-Help Enter-SshSession
Get-Help Remove-SshSession

http://www.powershelladmin.com/wiki/SSH_from_PowerShell_using_the_SSH.NET_library
#>



# Function to convert a secure string to a plain text password.
# See http://www.powershelladmin.com/wiki/Powershell_prompt_for_password_convert_securestring_to_plain_text
function ConvertFrom-SecureToPlain {
    
    param( [Parameter(Mandatory=$true)][System.Security.SecureString] $SecurePassword)
    
    # Create a "password pointer"
    $PasswordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
    
    # Get the plain text version of the password
    $PlainTextPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto($PasswordPointer)
    
    # Free the pointer
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($PasswordPointer)
    
    # Return the plain text password
    $PlainTextPassword
    
}

<#
.SYNOPSIS
Creates SSH sessions to remote SSH-compatible hosts, such as Linux
or Unix computers or network equipment. You can later issue commands
to be executed on one or more of these hosts.

.DESCRIPTION
Once you've created a session, you can use Invoke-SshCommand or Enter-SshSession
to send commands to the remote host or hosts.

The authentication is done here. If you specify -KeyFile, that will be used.
If you specify a password and no key, that will be used. If you do not specify
a key nor a password, you will be prompted for a password, and you can enter
it securely with asterisks displayed in place of the characters you type in.

.PARAMETER ComputerName
Required. DNS names or IP addresses for target hosts to establish
a connection to using the provided username and key/password.
.PARAMETER Username
Required. The username used for connecting.
.PARAMETER KeyFile
Optional. Specify the path to a private key file for authenticating.
Overrides a specified password.
.PARAMETER Password
Optional. You can specify a key, or leave out the password to be prompted
for a password which is typed in interactively and will not be displayed.
.PARAMETER Port
Optional. Default 22. Target port the SSH server uses.
#>
function New-SshSession {
    
    param([Parameter(Mandatory=$true)][string[]] $ComputerName,
          [Parameter(Mandatory=$true)][string]   $Username,
          [string] $KeyFile = '',
          [string] $Password = 'SvendsenTechDefault', # I guess allowing for a blank password is "wise"...
          [int] $Port = 22
    )
    
    if ($KeyFile -ne '') {
        
        "Key file specified. Will override password. Trying to read key file..."
        
        if (Test-Path -PathType Leaf -Path $Keyfile) {
            
            $Key = New-Object Renci.SshNet.PrivateKeyFile( $Keyfile )
            
        }
        
        else {
            
            "Specified keyfile does not exist: '$KeyFile'."
            return
            
        }
        
    }
    
    else {
        
        $Key = $false
        
    }
    
    # Prompt for password if none was supplied on the command line, and no key was provided.
    if (-not $Key -and $Password -ceq 'SvendsenTechDefault') {
        
        $SecurePassword = Read-Host -AsSecureString "No key provided. Enter SSH password for $Username"
        $Password = ConvertFrom-SecureToPlain $SecurePassword
        
    }
    
    # Let's start creating sessions and storing them in $global:SshSessions
    foreach ($Computer in $ComputerName) {
        
        if ($global:SshSessions.ContainsKey($Computer) -and $global:SshSessions.$Computer.IsConnected) {
            
            "You are already connected to $Computer"
            continue
            
        }
        
        try {
            
            if ($Key) {
                
                $SshClient = New-Object Renci.SshNet.SshClient($Computer, $Port, $Username, $Key)
                
            }
            
            else {
                
                $SshClient = New-Object Renci.SshNet.SshClient($Computer, $Port, $Username, $Password)
                
            }
            
        }
        
        catch {
            
            "Unable to create SSH client object for ${Computer}: $_"
            continue
            
        }
        
        try {
        
            $SshClient.Connect()
        
        }
        
        catch {
            
            "Unable to connect to ${Computer}: $_"
            continue
            
        }
        
        if ($SshClient -and $SshClient.IsConnected) {
            
            "Successfully connected to $Computer"
            $global:SshSessions.$Computer = $SshClient
            
        }
        
        else {
            
            "Unable to connect to ${Computer}"
            continue
            
        }
        
    } # end of foreach
    
    # Shrug... Can't hurt although I guess they should go out of scope here anyway.
    $SecurePassword, $Password = $null, $null
    
}

<#
.SYNOPSIS
Invoke/run commands via SSH on target hosts to which you have already opened
connections using New-SshSession. See Get-Help New-SshSession.

.DESCRIPTION
Execute/run/invoke commands via SSH.

You are already authenticated and simply specify the target(s) and the command.

Output is emitted to the pipeline, so you collect results by using:
$Result = Invoke-SshCommand [...]

$Result there would be either a System.String if you target a single host or a
System.Array containing strings if you target multiple hosts.

If you do not specify -Quiet, you will also get colored Write-Host output - mostly
for the sake of displaying progress.

Use -InvokeOnAll to invoke on all hosts to which you have opened connections.
The hosts will be processed in alphabetically sorted order.

.PARAMETER ComputerName
Target hosts to invoke command on.
.PARAMETER Command
Required. The Linux command to run on specified target computers.
.PARAMETER Quiet
Causes no colored output to be written by Write-Host. If you assign results to a
variable, no progress indication will be shown.
.PARAMETER InvokeOnAll
Invoke the specified command on all computers for which you have an open connection.
Overrides -ComputerName, but you will be asked politely if you want to continue,
if you specify both parameters.
#>
function Invoke-SshCommand {
    
    param([string[]] $ComputerName, # can't have it mandatory due to -InvokeOnAll...
          [Parameter(Mandatory=$true)][string] $Command,
          [switch] $Quiet,
          [switch] $InvokeOnAll
    )
    
    if ($InvokeOnAll) {
        
        if ($ComputerName) {
            
            $Answer = Read-Host -Prompt "You specified both -InvokeOnAll and -ComputerName. -InvokeOnAll overrides and targets all hosts.`nAre you sure you want to continue? (y/n) [yes]"
            if ($Answer -imatch '^n') { return }
            
        }
        
        if ($global:SshSessions.Keys.Count -eq 0) {
            
            "-InvokeOnAll specified, but no hosts found."
            return
            
        }
        
        # Get all computer names from the global SshSessions hashtable.
        $ComputerName = $global:SshSessions.Keys | Sort-Object
        
    }
    
    if (-not $ComputerName) {
        
        "No computer names specified and -InvokeOnAll not specified. Can not continue."
        return
        
    }
    
    foreach ($Computer in $ComputerName) {
        
        if (-not $global:SshSessions.ContainsKey($Computer)) {
            
            Write-Host -Fore Red "No SSH session found for $Computer. See Get-Help New-SshSession. Skipping."
            "No SSH session found for $Computer. See Get-Help New-SshSession. Skipping."
            continue
            
        }
        
        if (-not $global:SshSessions.$Computer.IsConnected) {
            
            Write-Host -Fore Red "You are no longer connected to $Computer. Skipping."
            "You are no longer connected to $Computer. Skipping."
            continue
            
        }
        
        $CommandObject = $global:SshSessions.$Computer.RunCommand($Command)
        
        # Write pretty, colored results with Write-Host unless the quiet switch is provided.
        if (-not $Quiet) {
            
            if ($CommandObject.ExitStatus -eq 0) {
                
                Write-Host -Fore Green -NoNewline "${Computer}: "
                Write-Host -Fore Cyan ($CommandObject.Result -replace '[\r\n]+\z', '')
                
            }
            
            else {
                
                Write-Host -Fore Green -NoNewline "${Computer} "
                Write-Host -Fore Yellow 'had an error:' ($CommandObject.Error -replace '[\r\n]+\z', '')
                
            }
            
        }
        
        # Now emit to the pipeline
        if ($CommandObject.ExitStatus -eq 0) {
            
            # Emit results to the pipeline. Twice the fun unless you're assigning the results to a variable.
            # Changed from .Trim(). Remove the trailing carriage returns and newlines that might be there,
            # in case leading whitespace matters in later processing. Not sure I should even be doing this.
            $CommandObject.Result -replace '[\r\n]+\z', ''
            
        }
        
        else {
            
            # Emit error to the pipeline. Twice the fun unless you're assigning the results to a variable.
            # Changed from .Trim(). Remove the trailing carriage returns and newlines that might be there,
            # in case leading whitespace matters in later processing. Not sure I should even be doing this.
            $CommandObject.Error -replace '[\r\n]+\z', ''
            
        }
        
        $CommandObject.Dispose()
        $CommandObject = $null
        
    }
    
}

<#
.SYNOPSIS
Enter a primitive interactive SSH session against a target host.
Commands are executed on the remote host as you type them and you are
presented with a Linux-like prompt.

.DESCRIPTION
Enter commands that will be executed by the host you specify and have already
opened a connection to with New-SshSession.

You can not change the current working directory on the remote host.

.PARAMETER ComputerName
Required. Target host to connect with.
.PARAMETER NoPwd
Optional. Do not try to include the default remote working directory in the prompt.
#>
function Enter-SshSession {
    
    param([Parameter(Mandatory=$true)][string] $ComputerName,
          [switch] $NoPwd
    )
    
    if (-not $global:SshSessions.ContainsKey($ComputerName)) {
            
        "No SSH session found for $Computer. See Get-Help New-SshSession. Skipping."
        return
            
    }
    
    if (-not $global:SshSessions.$ComputerName.IsConnected) {
        
        "The connection to $Computer has been lost"
        return
        
    }
    
    $SshPwd = ''
    
    # Get the default working dir of the user (won't be updated...)
    if (-not $NoPwd) {
        
        $SshPwdResult = $global:SshSessions.$ComputerName.RunCommand('pwd')
        
        if ($SshPwdResult.ExitStatus -eq 0) {
            
            $SshPwd = $SshPwdResult.Result.Trim()
            
        }
        
        else {
            
            $SshPwd = '(pwd failed)'
             
        }
        
    }
    
    $Command = ''
    
    while (1) {
        
        if (-not $global:SshSessions.$ComputerName.IsConnected) {
            
            "Connection to $Computer lost"
            return
            
        }
        
        $Command = Read-Host -Prompt "[$ComputerName]: $SshPwd # "
        
        # Break out of the infinite loop if they type "exit" or "quit"
        if ($Command -ieq 'exit' -or $Command -ieq 'quit') { break }
        
        $Result = $global:SshSessions.$ComputerName.RunCommand($Command)
        
        if ($Result.ExitStatus -eq 0) {
            
            $Result.Result -replace '[\r\n]+\z', ''
            
        }
        
        else {
            
            $Result.Error -replace '[\r\n]+\z', ''
            
        }
        
    } # end of while
    
}

<#
.SYNOPSIS
Removes opened SSH connections. Use the parameter -RemoveAll to remove all connections.

.DESCRIPTION
Performs disconnect (if connected) and dispose on the SSH client object, then
sets the $global:SshSessions hashtable value to $null and then removes it from
the hashtable.

.PARAMETER ComputerName
The names of the hosts for which you want to remove connections/sessions.
.PARAMETER RemoveAll
Removes all open connections and effectively empties the hash table.
Overrides -ComputerName, but you will be asked politely if you are sure,
if you specify both.
#>
function Remove-SshSession {
    
    param([string[]] $ComputerName, # can't have it mandatory due to -RemoveAll
          [switch]   $RemoveAll
    )
    
    if ($RemoveAll) {
        
        if ($ComputerName) {
            
            $Answer = Read-Host -Prompt "You specified both -RemoveAll and -ComputerName. -RemoveAll overrides and removes all connections.`nAre you sure you want to continue? (y/n) [yes]"
            if ($Answer -imatch '^n') { return }
            
        }
        
        if ($global:SshSessions.Keys.Count -eq 0) {
            
            "-RemoveAll specified, but no hosts found."
            return
            
        }
        
        # Get all computer names from the global SshSessions hashtable.
        $ComputerName = $global:SshSessions.Keys | Sort-Object
        
    }
    
    if (-not $ComputerName) {
        
        "No computer names specified and -RemoveAll not specified. Can not continue."
        return
        
    }
    
    foreach ($Computer in $ComputerName) {
        
        if (-not $global:SshSessions.ContainsKey($Computer)) {
            
            "The global `$SshSessions variable doesn't contain a session for $Computer. Skipping."
            continue
            
        }
        
        $ErrorActionPreference = 'Continue'
        
        if ($global:SshSessions.$Computer.IsConnected) { $global:SshSessions.$Computer.Disconnect() }
        $global:SshSessions.$Computer.Dispose()
        $global:SshSessions.$Computer = $null
        $global:SshSessions.Remove($Computer)
        
        $ErrorActionPreferene = 'Stop'
        
        "$Computer should now be disconnected and disposed."
        
    }
    
}

<#
.SYNOPSIS
Shows all, or the specified, SSH sessions in the global $SshSessions variable,
along with the connection status.

.DESCRIPTION
It checks if they're still reported as connected and reports that too. However,
they can have a status of "connected" even if the remote computer has rebooted.
Seems like an issue with the SSH.NET library and how it maintains this status.

If you specify hosts with -ComputerName, which don't exist in the $SshSessions
variable, the "Connected" value will be "NULL" for these hosts.

Also be aware that with the version of the SSH.NET library at the time of writing,
the host will be reported as connected even if you use the .Disconnect() method
on it. When you invoke the .Dispose() method, it does report the connection status
as false.

.PARAMETER ComputerName
Optional. The default behavior is to list all hosts alphabetically, but this
lets you specify hosts to target specifically. NULL is returned as the connection
status if a non-existing host name/IP is passed in.
#>
function Get-SshSession {
    
    param( [string[]] $ComputerName )
    
    # Just exit with a message if there aren't any connections.
    if ($global:SshSessions.Count -eq 0) { "No connections found"; return }
    
    # Unless $ComputerName is specified, use all hosts in the global variable, sorted alphabetically.
    if (-not $ComputerName) { $ComputerName = $global:SshSessions.Keys | Sort-Object }
    
    $Properties =
        @{n='ComputerName';e={$_}},
        @{n='Connected';e={
            
            # Ok, this isn't too pretty... Populate non-existing objects'
            # "connected" value with "NULL".
            if ($global:SshSessions.ContainsKey($_)) {
                
                $global:SshSessions.$_.IsConnected
                
            }
            else {
                
                'NULL'
                
            }
        }}
    
    # Process the hosts and emit output to the pipeline.
    $ComputerName | Select-Object $Properties
    
}

######## END OF FUNCTIONS ########

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$global:SshSessions = @{}

Export-ModuleMember New-SshSession, Invoke-SshCommand, Enter-SshSession, `
                    Remove-SshSession, Get-SshSession, ConvertFrom-SecureToPlain

