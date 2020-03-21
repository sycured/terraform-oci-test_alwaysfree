# terraform-oci-test_alwaysfree
little test with Oracle Cloud Always Free

## RSA KEY for API access
### create
```
mkdir ~/.oci
openssl genrsa -out ~/.oci/oci_api_key.pem 8192
openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem
```

### copy public key to paste on OCI website
`cat ~/.oci/oci_api_key_public.pem | pbcopy`

paste on https://console.sa-saopaulo-1.oraclecloud.com/identity/users/ocid1.user.oc1../api-keys

### copy fingerprint to paste on your .tfvars or override.tf
`openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | openssl md5 -c`

## Network
Protocol 6 = TCP

## Variables
### Default provided
- instance_shape: "VM.Standard.E2.1.Micro"
- os_major_version: 7


### You need to provide
- compartment_ocid
- fingerprint
- private_key_path
- region
- ssh_public_key
- tenancy_ocid
- user_ocid
