# todo - only update if necessary

# Write-Host "Updating package provider..."
# Install-Module -Force -Name PackageManagement -MinimumVersion 1.4.6 -Scope CurrentUser -AllowClobber

# todo - only install tools as needed

# Write-Host "Installing AWS tools..."
# $packages = @("AWS.Tools.SimpleSystemsManagement", "AWS.Tools.SecurityToken")

# Foreach ($package in $packages) {
#     Write-Host "Installing $package"
#     Find-Module -Name $package
#     Save-Module -Force -Name $package -Path "$env:USERPROFILE\\Documents\WindowsPowerShell\Modules"
#     Install-Module -Force -Name $package
# }

# Write-Host "Done installing, continuing to connect."

$hostAddress = "ashley-sbx-ssmpoc-mysql-exdhv.cluster-c78mwgqim3ye.ap-southeast-2.rds.amazonaws.com"
$port = '3306'
$localPort = "5$port"

$roleArn = "arn:aws:iam::202533530829:role/AdminRole"
$mfaDeviceArn = "arn:aws:iam::800891318996:mfa/Personal-Phone"
$identityProfile = "gb-identity"
$actingProfile = "gb-ssm"
$sessionName = "db-tunnel"
$region = "ap-southeast-2"

$bastionInstanceId = "i-0590dff587e0024b8"

$token = Read-Host "MFA token"

Set-DefaultAWSRegion -Region $region
Set-AWSCredential -ProfileName $identityProfile

$response = Use-STSRole -RoleArn $roleArn -RoleSessionName $sessionName -SerialNumber $mfaDeviceArn -Token $token
$credentials = New-AWSCredentials -AccessKey $response.Credentials.AccessKeyId -SecretKey $response.Credentials.SecretAccessKey -SessionToken $response.Credentials.SessionToken

# switch to the assumed role
Set-AWSCredential -StoreAs $actingProfile -Credential $credentials
Set-AWSCredential -ProfileName $actingProfile

# todo - get values from terraform


Start-SSMSession -Target $bastionInstanceId -DocumentName "AWS-StartPortForwardingSessionToRemoteHost" -Parameter @{ host = $hostAddress; portNumber = $port; localPortNumber = $localPort }
