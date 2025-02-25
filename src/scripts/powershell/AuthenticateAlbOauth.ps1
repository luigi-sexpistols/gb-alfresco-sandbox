$roleArn = "arn:aws:iam::145023138872:role/OrganizationAccountAccessRole"
$mfaDeviceArn = "arn:aws:iam::800891318996:mfa/Personal-Phone"
$identityProfile = "gb-identity"
$actingProfile = "terraform-alb-oauth"
$sessionName = "terraform-2"
$region = "ap-southeast-2"

$token = Read-Host "MFA token"

$awsCredsFile = "~/.aws/credentials" | Resolve-Path

Set-DefaultAWSRegion -Region $region
Set-AWSCredential -ProfileLocation $awsCredsFile -ProfileName $identityProfile

$response = Use-STSRole -RoleArn $roleArn -RoleSessionName $sessionName -SerialNumber $mfaDeviceArn -Token $token
$credential = New-AWSCredentials -AccessKey $response.Credentials.AccessKeyId -SecretKey $response.Credentials.SecretAccessKey -SessionToken $response.Credentials.SessionToken
Set-AWSCredential -ProfileLocation $awsCredsFile -StoreAs $actingProfile -Credential $credential
Set-AWSCredential -ProfileLocation $awsCredsFile -ProfileName $actingProfile

Write-Host "Done, use profile ""$actingProfile""."
