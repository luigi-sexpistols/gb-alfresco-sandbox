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

# todo - DRY this code out (auth stuff in its own script, etc)

$port = '22'
$localPort = "22$port"

$roleArn = "arn:aws:iam::202533530829:role/AdminRole"
$mfaDeviceArn = "arn:aws:iam::800891318996:mfa/Personal-Phone"
$identityProfile = "gb-identity"
$actingProfile = "gb-ssm"
$sessionName = "instance-connect"
$region = "ap-southeast-2"

$targetInstanceId = "i-0590dff587e0024b8"
$document = "AWS-StartPortForwardingSession"

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

# todo - get values from terraform

Write-Host "Connect to `ec2-user@localhost:$localPort`."

Set-Alias -Name aws -Value "C:\Program Files\Amazon\AWSCLIV2\aws.exe"

$paramsFile = New-TemporaryFile
Set-Content -Path $paramsFile -Value (@{portNumber = @($port); localPortNumber = @($localPort)} | ConvertTo-Json -Compress)

aws --profile=$actingProfile --region $region --ca-bundle $awsCaBundleFile ssm start-session --target=$targetInstanceId --document-name=$document --parameters="file://$paramsFile"
