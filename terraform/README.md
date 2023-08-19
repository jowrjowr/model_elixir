## CLI config

Create a team or user token in the control panel on app.terraform.io and add the following to `~/.terraformrc`

```HCL
credentials "app.terraform.io" {
  token = "REPLACE_ME"
}
```

### Environment

What environment is this being run in?

Example:

```bash
cd environments/dev
```

### AWS keypair

Example:

```bash
export TF_VAR_key_name="keypair"
```

or don't, and terraform will just ask you

## Deployment

***Make sure you have MFA configured***

See [AWS Documentation](https://aws.amazon.com/iam/features/mfa/) for details.

Set your AWS Secrets in ~/.aws/credentials as such:

```
[default]
aws_access_key_id = <what IAM tells you>
aws_secret_access_key = <what IAM tells you>
```

Setup AWS temporary token:

```bash
aws_mfa <MFA token>
```
#### Note:
aws_mfa is a helper function loaded into the environment via shell.nix rather
than a specific binary. Read  [Technical details on AWS CLI MFA Usage](https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/) for more information.

Run the following commands:

```bash
terraform init
terraform plan
```

**PAUSE** here - read the output from the plan and make sure it is going to do what you expect it to do.

Apply the plan:

```bash
terraform apply
```


