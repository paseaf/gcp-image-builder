# GCP Image Builder

This repo creates GCP images with latest software preinstalled using Packer.

These images are used to create VMs on GCP.

Images are recreated daily with the help of GitHub Actions.

Currently supported distros:

| Distro              | image-name      |
| ------------------- | --------------- |
| `Ubuntu Pro 18 LTS` | `ubuntu-pro-18` |
| `Ubuntu Pro 20 LTS` | `ubuntu-pro-20` |
| `Ubuntu Pro 22 LTS` | `ubuntu-pro-22` |

### How to create VM with images

```bash
./create_vm.sh
# follow the prompt to select version

# optional: copy to PATH
cp ./create_vm.sh ~/bin/
```

### Running Packer on local machine

Prerequisite: `gcloud` and `packer` cli

```bash
cd packer
packer init .
# use default project and zone
./build_all.sh $(gcloud config get project) $(gcloud config get compute/zone)
```

### Running Packer on GitHub Actions

> Modified based on:
> https://github.com/marketplace/actions/authenticate-to-google-cloud#setup

0. Enable APIs

   ```bash
   gcloud services enable compute.googleapis.com
   gcloud init
   gcloud auth application-default login
   ```

1. Set up GCP authentication for GitHub Actions

   ```bash
   export PROJECT_ID="$(gcloud config get project)" # use gcloud default project
   export POOL_NAME=github
   export PROVIDER=github-actions

   # 1. set service_account
   # Create a service account and grant permissions for Packer
   export SERVICE_ACCOUNT_NAME=github-actions
   gcloud iam service-accounts create "$SERVICE_ACCOUNT_NAME" \
       --description="service account for running github actions" \
       --display-name="GitHub Actions" \
       --project "$PROJECT_ID"

   gcloud projects add-iam-policy-binding "$PROJECT_ID" \
       --member="serviceAccount:"$SERVICE_ACCOUNT_NAME"@$PROJECT_ID.iam.gserviceaccount.com" \
       --role="roles/compute.instanceAdmin.v1"
   gcloud projects add-iam-policy-binding "$PROJECT_ID" \
       --member="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
       --role="roles/iam.serviceAccountUser"
   gcloud projects add-iam-policy-binding "$PROJECT_ID" \
       --member="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
       --role=roles/iap.tunnelResourceAccessor

   # Set service account
   export SERVICE_ACCOUNT=$(gcloud iam service-accounts list | grep "GitHub Actions" | awk '{print $3}')
   echo "$SERVICE_ACCOUNT"


   # 2. enable IAM crednetials API
   gcloud services enable iamcredentials.googleapis.com \
     --project "${PROJECT_ID}"

   # 3. Create a Workload Identity Pool:
   gcloud iam workload-identity-pools create "$POOL_NAME" \
     --project="${PROJECT_ID}" \
     --location="global" \
     --display-name="GitHub Actions workload pool"

   # 4. Get the full ID of the Workload Identity Pool:
   gcloud iam workload-identity-pools describe "$POOL_NAME" \
     --project="${PROJECT_ID}" \
     --location="global" \
     --format="value(name)"

   export WORKLOAD_IDENTITY_POOL_ID=$(gcloud iam workload-identity-pools list \
     --location=global | grep -C 1 "GitHub Actions" | grep name | awk '{print $2}')
   echo "$WORKLOAD_IDENTITY_POOL_ID"

   # 5. Create a Workload Identity Provider in that pool:
   gcloud iam workload-identity-pools providers create-oidc "$PROVIDER" \
     --project="${PROJECT_ID}" \
     --location="global" \
     --workload-identity-pool="$POOL_NAME" \
     --display-name="GitHub Actions Provider" \
     --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
     --issuer-uri="https://token.actions.githubusercontent.com"

   # 6. Allow Authentications
   export REPO="paseaf/gcp-image-builder" # username/repo
   gcloud iam service-accounts add-iam-policy-binding "$SERVICE_ACCOUNT" \
     --project="${PROJECT_ID}" \
     --role="roles/iam.workloadIdentityUser" \
     --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${REPO}"
   ```

2. Set the following secrets to GitHub actions

   ```bash
   echo "# WORKLOAD_IDENTITY_PROVIDER: \
   $(gcloud iam workload-identity-pools providers describe $PROVIDER \
     --project=$PROJECT_ID \
     --location=global \
     --workload-identity-pool="$POOL_NAME" \
     --format='value(name)')"

   echo "# SERVICE_ACCOUNT: $(gcloud iam service-accounts list | grep 'GitHub Actions' | awk '{print $3}')"

   echo "# PKR_VAR_PROJECT_ID: $(gcloud config get project)"

   echo "# PKR_VAR_ZONE: $(gcloud config get compute/zone)"
   ```
