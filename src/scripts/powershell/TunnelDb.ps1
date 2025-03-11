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

$engine = Read-Host "DB Engine [oracle|mssql]"

#$hostAddress = "ashley-sbx-ssmpoc-mysql-exdhv.cluster-c78mwgqim3ye.ap-southeast-2.rds.amazonaws.com"
#$port = '3306'

$adminUsername = terraform -chdir='./src/projects/ssm-access' output -raw "$($engine)_admin_username"
$adminPassword = terraform -chdir='./src/projects/ssm-access' output -raw "$($engine)_admin_password"
$hostAddress = terraform -chdir='./src/projects/ssm-access' output -raw "$($engine)_host"
$hostPort = terraform -chdir='./src/projects/ssm-access' output -raw "$($engine)_port"

$localPort = "5$hostPort"

$roleArn = "arn:aws:iam::202533530829:role/AdminRole"
$mfaDeviceArn = "arn:aws:iam::800891318996:mfa/Personal-Phone"
$identityProfile = "gb-identity"
$actingProfile = "gb-ssm"
$sessionName = "db-tunnel"
$region = "ap-southeast-2"

$bastionInstanceId = "i-09cf1e833b7b15394"
$document = "AWS-StartPortForwardingSessionToRemoteHost"

$awsCredsFile = "~/.aws/credentials" | Resolve-Path
$awsCaBundleFile = "~/Downloads/ZscalerRootCertificate-2048-SHA256.crt" | Resolve-Path

$token = Read-Host "MFA token"

Set-DefaultAWSRegion -Region $region
Set-AWSCredential -ProfileName $identityProfile

$response = Use-STSRole -RoleArn $roleArn -RoleSessionName $sessionName -SerialNumber $mfaDeviceArn -Token $token
$credential = New-AWSCredential -AccessKey $response.Credentials.AccessKeyId -SecretKey $response.Credentials.SecretAccessKey -SessionToken $response.Credentials.SessionToken

# switch to the assumed role
Set-AWSCredential -ProfileLocation $awsCredsFile -StoreAs $actingProfile -Credential $credential
# OR use assume-role directly? (doesn't seem to work 2025-02-24)
# Set-AWSCredential -StoreAs $actingProfile -SourceProfile $identityProfile -RoleArn $roleArn -MfaSerial $mfaDeviceArn
Set-AWSCredential -ProfileLocation $awsCredsFile -ProfileName $actingProfile

Write-Host ""
Write-Host "Host: 127.0.0.1"
Write-Host "Port: $localPort"
Write-Host "Username: $adminUsername"
Write-Host "Password: $adminPassword"
Write-Host ""

Set-Alias -Name aws -Value "C:\Program Files\Amazon\AWSCLIV2\aws.exe"

$paramsFile = New-TemporaryFile
Set-Content -Path $paramsFile -Value (@{
    host = @($hostAddress)
    portNumber = @($hostPort)
    localPortNumber = @($localPort)
} | ConvertTo-Json -Compress)

aws --profile=$actingProfile --region $region --ca-bundle $awsCaBundleFile ssm start-session --target=$bastionInstanceId --document-name=$document --parameters="file://$paramsFile"
