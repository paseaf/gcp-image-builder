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
export PROJECT_ID="my-project" # update with your value
export POOL_NAME=github
export PROVIDER=github-actions

# 1. set service_account
export SERVICE_ACCOUNT=<service_account>
# Use an existing service account
gcloud iam service-accounts list
# OR create service account
gcloud iam service-accounts create "my-service-account" \
  --project "${PROJECT_ID}"


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

export WORKLOAD_IDENTITY_POOL_ID=<identity-pool-id>

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
gcloud iam service-accounts add-iam-policy-binding "SERVICE_ACCOUNT" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${REPO}"
```

2. Get Values for GitHub Secrets

```bash
# Get WORKLOAD_IDENTITY_PROVIDER
gcloud iam workload-identity-pools providers describe "PROVIDER" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="POOL_NAME" \
  --format="value(name)"

# Get SERVICE_ACCOUNT
gcloud iam service-accounts list

# Get PKR_VAR_project_id
gcloud config get project
# Get PKR_VAR_zone
gcloud config get compute/zone
```
