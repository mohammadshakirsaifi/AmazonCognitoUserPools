# Cognito + Okta Terraform Complete Setup
# 🚀 Cognito + Okta Terraform Lab

This project automates integration between Okta and AWS Cognito using Terraform. It supports both CI/CD with GitHub Actions and local deployment via Bash scripts.

### 📁 Project Structure
```bash
cognito-okta-terraform-complete/
├── main.tf                    # Terraform resources
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── terraform.tfvars.example  # Example variable definitions
├── deploy.sh                 # Local deployment script
├── destroy.sh                # Cleanup script
├── README.md                 # Documentation
├── scripts/
│   └── okta-create-oidc.sh    # Script to create OIDC app in Okta
└── .github/
    └── workflows/
        └── deploy.yml         # GitHub Actions workflow
```
---
###  ✅ Prerequisites
Ensure the following tools and accounts are set up before deploying:
- ✅ Okta Organization with admin privileges
- ✅ Okta API Token
- ✅ AWS CLI installed and configured
- ✅ Terraform ≥ 1.5.0 installed
- ✅ jq installed (for JSON parsing in scripts)

### 🔑 Required Values

Before running deployment, gather the following:

OKTA_DOMAIN (e.g., dev-123456.okta.com)

OKTA_API_TOKEN

OktaClientId and OktaClientSecret (from okta-create-oidc.sh)

CallbackURL and LogoutURL for your app

CognitoDomainPrefix (must be unique for the Cognito Hosted UI)

### 🚀 Deployment Options
### Option 1: GitHub Actions (CI/CD)

The provided GitHub Actions workflow (.github/workflows/deploy.yml) will automatically:

Initialize Terraform (terraform init)

Validate configuration (terraform validate)

Show plan (terraform plan)

Apply configuration (terraform apply)

Trigger: On every push to the repository.

### Option 2: Local Deployment via Bash

For local testing or development, use the deploy.sh script.
```bash
chmod +x deploy.sh
./deploy.sh
```

Steps:

Update terraform.tfvars with your values.

Run the script.

Terraform will automatically initialize, validate, plan, and apply.

### 🔄 Okta OIDC App Creation

Run the script to create an OIDC app in Okta:
```bash
scripts/okta-create-oidc.sh
```

It will output:

- `client_id`
- `client_secret`

Copy these into `terraform.tfvars`.

### 🧩 Login Flow Test

After deployment, test login via the Cognito Hosted UI:
```bash
https://<CognitoDomainPrefix>.auth.<region>.amazoncognito.com/oauth2/authorize
  ?response_type=code
  &client_id=<CognitoAppClientId>
  &redirect_uri=<CallbackURL>
  &scope=openid+email+profile
  &identity_provider=OktaOIDC
```
### 🗑️ Tear Down / Cleanup

To clean up all created resources:
```bash
chmod +x destroy.sh
./destroy.sh
```

You will be prompted:
```bash
⚠️  WARNING: This will destroy all Terraform-managed resources for Cognito-Okta integration!
Are you sure you want to continue? (yes/no):
```

Type yes to confirm. This helps avoid unnecessary cloud costs.
