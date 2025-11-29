# Troubleshooting Guide

## GitHub Actions Permission Issues

### ❌ Problem: "Permission denied to enable service"

**Error message:**
```
ERROR: (gcloud.services.enable) does not have permission to access projects instance
Permission denied to enable service [artifactregistry.googleapis.com]
```

**Root Cause:**
The service account used by GitHub Actions doesn't have the `roles/serviceusage.serviceUsageAdmin` role, which is required to enable GCP APIs.

**Solution:**
We changed the workflow to **verify** APIs are enabled (read-only) instead of trying to **enable** them (requires admin permissions).

**Prerequisites:**
APIs must be enabled **before** running the workflow. Enable them once using:

```bash
gcloud services enable \
  artifactregistry.googleapis.com \
  run.googleapis.com \
  cloudbuild.googleapis.com \
  firestore.googleapis.com \
  eventarc.googleapis.com \
  pubsub.googleapis.com \
  --project=car-inspectinator-3000
```

**Status:** ✅ Fixed in commit `f10a82f`

---

## Local Development Issues

### ❌ Problem: "Reauthentication is needed"

**Error message:**
```
Error retrieving cars from Firestore: Timeout of 300.0s exceeded
Getting metadata from plugin failed with error: Reauthentication is needed
```

**Solution:**
Set up Application Default Credentials (ADC):

```bash
gcloud auth application-default login
```

**Why this happens:**
There are two types of authentication:
1. **User authentication** (`gcloud auth login`) - For CLI commands
2. **Application Default Credentials** (`gcloud auth application-default login`) - For your code

Your application code needs ADC to access GCP services.

---

## Firestore Issues

### ❌ Problem: "Missing or insufficient permissions" (403)

**Error message:**
```
Error retrieving cars from Firestore: 403 Missing or insufficient permissions.
```

**Symptoms:**
- API returns empty array `[]`
- Cloud Run logs show 403 permission error
- Service can't read from Firestore

**Root Cause:**
The Cloud Run service account doesn't have the necessary Firestore permissions.

**Solution:**
Grant the `roles/datastore.user` role to your Cloud Run service account:

```bash
# Replace backend-service with your actual service account name
gcloud projects add-iam-policy-binding car-inspectinator-3000 \
  --member="serviceAccount:backend-service@car-inspectinator-3000.iam.gserviceaccount.com" \
  --role="roles/datastore.user"
```

**Note:** After granting permissions, new Cloud Run instances will have access. Existing instances may need a few minutes to pick up the new permissions, or you can force a new deployment.

**Status:** ✅ Fixed - permissions granted

---

### ❌ Problem: "Cloud Firestore API has not been used"

**Error message:**
```
403 Cloud Firestore API has not been used in project before or it is disabled
```

**Solution:**
Enable the Firestore API:

```bash
gcloud services enable firestore.googleapis.com --project=car-inspectinator-3000
```

### ❌ Problem: "Database does not exist"

**Solution:**
Create a Firestore database:

```bash
gcloud firestore databases create \
  --location=nam5 \
  --project=car-inspectinator-3000
```

### ❌ Problem: "No cars returned from API"

**Possible Causes:**
1. **Empty database** - Database needs to be seeded
2. **Permission issues** - See "Missing or insufficient permissions" above

**Solution 1: Seed the database**
```bash
cd cloud/containers/car-service
python3 seed_firestore.py
```

**Solution 2: Check permissions**
Verify the service account has `roles/datastore.user` role (see above)

**Tip:** When testing the API, avoid trailing slashes in URLs:
- ✅ Use: `https://car-service-xxx.run.app/v1/cars`
- ⚠️  Avoid: `https://car-service-xxx.run.app/v1/cars/` (causes 307 redirect)

---

## Artifact Registry Issues

### ❌ Problem: "Artifact Registry API not enabled"

**Error message:**
```
API [artifactregistry.googleapis.com] not enabled on project
```

**Solution:**
Enable the Artifact Registry API:

```bash
gcloud services enable artifactregistry.googleapis.com --project=car-inspectinator-3000
```

### ❌ Problem: "Repository does not exist"

**Solution:**
Create the Artifact Registry repository:

```bash
gcloud artifacts repositories create carinspectinator-services \
  --repository-format=docker \
  --location=europe-west1 \
  --description="CarInspectinator microservices container registry" \
  --project=car-inspectinator-3000
```

---

## Service Account Permissions

### Required Permissions for GitHub Actions Service Account

The service account configured in `GCP_SERVICE_ACCOUNT` secret needs these roles:

**Minimum required:**
- `roles/artifactregistry.writer` - Push Docker images
- `roles/run.admin` - Deploy Cloud Run services
- `roles/iam.serviceAccountUser` - Use service accounts
- `roles/serviceusage.serviceUsageViewer` - List enabled APIs (for verification)

**Optional (for API management):**
- `roles/serviceusage.serviceUsageAdmin` - Enable/disable APIs (not needed with current workflow)

### Granting Permissions

```bash
# Replace SERVICE_ACCOUNT_EMAIL with your actual service account email
SERVICE_ACCOUNT_EMAIL="your-sa@car-inspectinator-3000.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding car-inspectinator-3000 \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/artifactregistry.writer"

gcloud projects add-iam-policy-binding car-inspectinator-3000 \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding car-inspectinator-3000 \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding car-inspectinator-3000 \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/serviceusage.serviceUsageViewer"
```

---

## Quick Diagnostic Commands

### Check if APIs are enabled
```bash
gcloud services list --enabled --project=car-inspectinator-3000
```

### Check Firestore database status
```bash
gcloud firestore databases list --project=car-inspectinator-3000
```

### Check Artifact Registry repositories
```bash
gcloud artifacts repositories list \
  --location=europe-west1 \
  --project=car-inspectinator-3000
```

### Check Cloud Run services
```bash
gcloud run services list \
  --region=europe-west1 \
  --project=car-inspectinator-3000
```

### Test local API
```bash
curl http://localhost:8080/v1/cars | python3 -m json.tool
```

### Test deployed API
```bash
# Get service URL
SERVICE_URL=$(gcloud run services describe car-service \
  --region=europe-west1 \
  --project=car-inspectinator-3000 \
  --format='value(status.url)')

# Test API
curl ${SERVICE_URL}/v1/cars | python3 -m json.tool
```

---

## Common Workflow Failures

### "Image not found"
**Cause:** Docker image wasn't pushed to Artifact Registry
**Check:** Look for errors in the "Push Docker image" step

### "Service deployment failed"
**Cause:** Various - check Cloud Run logs
**Solution:**
```bash
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=car-service" \
  --limit=50 \
  --project=car-inspectinator-3000
```

### "Health check failed"
**Cause:** Service not responding at `/health` endpoint
**Check:** Verify the service is listening on port 8080

---

## Getting Help

1. **Check GitHub Actions logs:** https://github.com/oholmess/CarInspectinator/actions
2. **Check Cloud Run logs:** GCP Console → Cloud Run → car-service → Logs
3. **Check Firestore:** GCP Console → Firestore → Data
4. **Review documentation:**
   - `QUICKSTART.md` - Quick setup guide
   - `FIREBASE_SETUP.md` - Firebase integration details
   - `GCP_SETUP.md` - Complete GCP configuration

---

## Status Check Script

Save this as `check_status.sh`:

```bash
#!/bin/bash
PROJECT_ID="car-inspectinator-3000"

echo "=== GCP Status Check ==="
echo ""

echo "📡 Checking APIs..."
gcloud services list --enabled --filter="name:(artifactregistry|run|firestore|cloudbuild)" \
  --format="table(name)" --project=$PROJECT_ID

echo ""
echo "🗄️ Checking Firestore..."
gcloud firestore databases list --project=$PROJECT_ID

echo ""
echo "📦 Checking Artifact Registry..."
gcloud artifacts repositories list --location=europe-west1 --project=$PROJECT_ID

echo ""
echo "🚀 Checking Cloud Run services..."
gcloud run services list --region=europe-west1 --project=$PROJECT_ID

echo ""
echo "✅ Status check complete"
```

