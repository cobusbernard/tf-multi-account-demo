# aws-pretoria-meetup
Quick demo for the AWS Pretoria meetup on 2019-11-05 - slides available here: https://www.slideshare.net/CobusBernard/20191105-aws-pretoria-meetup-setting-up-your-first-environment-and-adding-automation


# Setup
## AWS Accounts
Create an AWS account, then via AWS Organisations set up 2 more accounts, called `development` and `production`. A useful hack here is to overload your email address, e.g. `me+aws-main@mydomain.com`, `me+aws-development@mydomain.com` and `me+aws-production@mydomain.com` will all be sent to `me@mydomain.com`, but are viewed as unique emails. Write down the account IDs of all 3. For the IAM role to give access to the child accounts, pick `AdminOrgRole`. For a step-by-step guid on setting up the multiple account, have a look at this webinar: https://emea-resources.awscloud.com/ssa-events-webinars/building-out-your-multi-account-infrastructure-webinar

## AWS CLI
Add your API key + secret to the `~/.aws/credentials` files as a named set:

~~~
[meetup-main]
aws_access_key_id = my_key
aws_secret_access_key = my_secret
~~~

Set up profiles to role switch to other accounts in `~/.aws/config`:

~~~
[profile meetup-main]
region = eu-west-1

[profile meetup-development]
region = eu-west-1
role_arn = arn:aws:iam::<your development account Id>:role/AdminOrgRole
source_profile = meetup-main

[profile meetup-production]
region = eu-west-1
role_arn = arn:aws:iam::<your production account Id>:role/AdminOrgRole
source_profile = meetup-main
~~~

Test the AWS CLI by running:

~~~
aws --profile meetup-main ec2 describe-vpcs
aws --profile meetup-development ec2 describe-vpcs
aws --profile meetup-production ec2 describe-vpcs
~~~

Your should receive a `json` response with details of any VPC that exists in the account. (New accounts have a default one, but you may have deleted yours if this is an existing account.)

## Terraform
Install Terraform `0.12.10`. You will also need to create a bucket to host the terraform statefiles, do so via the console, and create it in `eu-west-1` region. Update the `infra/terraform-state.tf` and `infra-env/terraform-state.tf` files: replace the placeholder in this line with your bucket name `bucket  = "my-terraform-statefile-bucket-name-here"`.

### Main Account
Change into the `infra` directory, update `environments/main/environments.tfvars` to use your `main` account's ID. Once done, run the following: `terraform init`. This creates a statefile in the S3 bucket, downloads providers, etc. It should complete without errors. You chould now be able to run `terraform plan -var-file=environments/main/environment.tfvars -out=plan.out`. This will show you what resources it will create. To create them, run `terraform apply plan.out`. If you want to tear down the resources, use `terraform destroy --var-file=environments/main/environment.tfvars`.

### Environment Accounts
Change into the `infra-envs` directory, update `environments/development/environments.tfvars` to use your `development` account's ID, and then also update `environments/pro/environments.tfvars` to use your `production` account's ID. Once done, run the following: 

~~~
terraform init  #This creates a statefile in the S3 bucket, downloads providers, etc. It should complete without errors. 
terraform workspace new development
terraform workspace new production
~~~

This will create separate workspaces in the S3 buckte to store the statefiles for each of these workspaces. You will now be able to run the `plan`, `apply` and `destroy` commands. The important point to note here is to always switch the workspace to the one you are working with. An easy way to do this is via environment variable, e.g.:

~~~
export TF_ENV=development; terraform workspace select $TF_ENV; terraform plan -var-file=environments/$TF_ENV/environment.tfvars -out=$TF_ENV.out
~~~

And you can the use `terraform apply development.plan`. To destroy the resources created, use:

~~~
export TF_ENV=development; terraform workspace select $TF_ENV; terraform destroy --var-file=environments/$TF_ENV/environment.tfvars
~~~

You can similarty replace `TF_ENV=development` with `TF_ENV=production` to work with your production account.
