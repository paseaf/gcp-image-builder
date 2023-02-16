# GCP Image Builder

Create GCP disk images with up-to-date software using Packer.

Currently supported distros:

- `Ubuntu Pro 18 LTS`
- `Ubuntu Pro 20 LTS`
- `Ubuntu Pro 22 LTS`

Images are updated periotically with GitHub Actions to get the latest software preinstalled.

### Creating VM with built image

```bash
./create_vm.sh
```

### Building Images Manually

```bash
cd packer
# use default project and zone
./build_all.sh $(gcloud config get project) $(gcloud config get compute/zone)
```

### Misc.

Configure GitHub Actions
https://github.com/marketplace/actions/authenticate-to-google-cloud#setup

1. Set up GCP for GitHub Actions

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

# Get service account
gcloud iam service-accounts list
# Set
export SERVICE_ACCOUNT=$(gcloud iam service-accounts list | grep "GitHub Actions" | awk '{print $3}')


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
echo $WORKLOAD_IDENTITY_POOL_ID

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

2. Get Values for GitHub Secrets

```bash
echo "# WORKLOAD_IDENTITY_PROVIDER:"
gcloud iam workload-identity-pools providers describe "$PROVIDER" \
  --project="$PROJECT_ID" \
  --location="global" \
  --workload-identity-pool="$POOL_NAME" \
  --format="value(name)"

echo "# SERVICE_ACCOUNT:"
gcloud iam service-accounts list | grep "GitHub Actions" | awk '{print $3}'

echo "# PKR_VAR_PROJECT_ID:"
gcloud config get project

echo "# PKR_VAR_ZONE:"
gcloud config get compute/zone
```
