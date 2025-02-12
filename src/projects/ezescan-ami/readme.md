# Connecting from Linux workstations

You will need to use an SSH tunnel to connect to the Windows host. I'm using it from the command line, but RDP clients
seem to provide options for configuring a tunnel within the connection settings.

## Using the CLI 

The generalisation of the command is as follows:

```shell
ssh {bastion_connection} -L {local_port}:{windows_host_private_address}:3889
```

My particular setup is:

```shell
# specify bastion details explicitly:
ssh -i ~/.ssh/{bastion_private_key_file} ec2-user@{bastion_ip} -L 133889:{ip}:3889

# use a host alias:
ssh bastion.sandbox.gb -L 133889:{ip}:3889
```

You can also supply the `-F` flag to send the tunnel process to the background, but this does make it more difficult to
exit when you're done.
