# kubernetes terraform

based on https://github.com/hobby-kube/guide

## Config

```bash
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export TF_VAR_digitalocean_token=""
```

State is stored in S3 with DynamoDB locking.

### Usage

```sh
# fetch the required modules
$ terraform init hobby-kube/

# see what `terraform apply` will do
$ terraform plan hobby-kube/

# execute it
$ terraform apply hobby-kube/
```
