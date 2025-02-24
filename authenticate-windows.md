## Setup

### Assume the Admin Role

```shell
aws --profile=gb-identity --no-verify-ssl sts assume-role --role-session-name terraform --role-arn arn:aws:iam::202533530829:role/AdminRole --serial-number arn:aws:iam::800891318996:mfa/Personal-Phone --token-code ''

aws --profile=terraform configure set aws_access_key_id ''
aws --profile=terraform configure set aws_secret_access_key ''
aws --profile=terraform configure set aws_session_token  ''
```
