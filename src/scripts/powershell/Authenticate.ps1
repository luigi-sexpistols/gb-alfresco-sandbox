$roleArn = "arn:aws:iam::202533530829:role/AdminRole"
$mfaDeviceArn = "arn:aws:iam::800891318996:mfa/Personal-Phone"
$identityProfile = "gb-identity"
$actingProfile = "terraform"
$sessionName = "terraform"
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
