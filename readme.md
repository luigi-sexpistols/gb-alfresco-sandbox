## Apply Order

![Apply order.](readme-files/sandbox-apply-order.png "Apply order.")

Note that the `Image Pipeline` step(s) are performed manually at this stage. 

## Scripts

### `authenticate.sh`

Use to authenticate with AWS and create a `terraform` profile with assumed role credentials. Copy `setenv.sh.dist` to
`setenv.sh` and fill in the missing details; the auth script will automatically pick up these values.

#### Usage

```shell
cp setenv.sh.dist setenv.sh
# enter details in setenv.sh
./authenticate
```

### `deploy.sh`

Convenience script for executing a deploy in a given project and environment. Can be used to `plan`, `apply`, and 
`destroy`.

#### Usage

All args are optional except `--project`.

| Argument            | Description                                                          |
|:--------------------|:---------------------------------------------------------------------|
| --home={path}       | Sets the working directory. Defaults to current working dir (`pwd`). |
| --project={project} | Maps directly to `src/projects/{project}`.                           |
| --environment={env} | Maps directly to `src/projects/project/{env}`.                       |
| --plan              | Sets the mode to `plan`. This is the default mode.                   | 
| --apply             | Sets the mode to `apply`.                                            |
| --destroy           | Sets the mode to `destroy`.                                          |
| --approve           | Automatically approves an `apply` or `destroy` command.              |

```shell
./deploy.sh --project=networking --apply
```

### `run-in-project-env.sh`

Used to run other Terraform commands like `init`.

#### Usage

| Argument            | Description                                                                   |
|:--------------------|:------------------------------------------------------------------------------|
| --home={path}       | Sets the working directory. Defaults to current working dir (`pwd`).          |
| --project={project} | Maps directly to `src/projects/{project}`.                                    |
| --environment={env} | Maps directly to `src/projects/{project}/{env}`.                              |
| --command={command} | The command to execute. Can be any bash command, but `terraform` is intended. | 

```shell
./run-in-project-env.sh --project=networking --environment=au-dev --command='terraform init -upgrade'
```

## Running in Windows

The first step is to call `sts:AssumeRole` to assume the admin role in the sandbox account. This requires an MFA token
from your authenticator app/device.

```shell
aws --profile=gb-identity sts assume-role\
  --role-session-name=terraform\
  --role-arn='arn:awn:iam::202533530829:role/AdminRole'\
  --serial-number='arn:aws:iam::800891318996:mfa/Personal-Phone'\
  --token-code='{MFA_TOKEN_FROM_PHONE}'
```

Use the values resulting from this to set the required AWS credentials:

```shell
aws --profile=terraform configure set aws_access_key_id '{ACCESS_KEY_ID}'
aws --profile=terraform configure set aws_secret_access_key '{ACCESS_KEY_SECRET}'
aws --profile=terraform configure set aws_session_token '{SESSION_TOKEN}'
```
