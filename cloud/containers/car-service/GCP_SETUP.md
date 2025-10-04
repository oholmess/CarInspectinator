# GCP Setup Complete ✅

This document tracks all the GCP services and configurations that have been set up for the Car Service.

## ✅ Enabled APIs

The following Google Cloud APIs have been enabled for project `car-inspectinator-3000`:

1. **Firestore API** (`firestore.googleapis.com`)
   - For storing car data in Firestore database
   
2. **Artifact Registry API** (`artifactregistry.googleapis.com`)
   - For storing Docker container images
   
3. **Cloud Run API** (`run.googleapis.com`)
   - For deploying and running containerized services
   
4. **Cloud Build API** (`cloudbuild.googleapis.com`)
   - For building Docker images
   
5. **Container Registry API** (`containerregistry.googleapis.com`)
   - Legacy container registry support
   
6. **Eventarc API** (`eventarc.googleapis.com`)
   - For event-driven architecture
   
7. **Pub/Sub API** (`pubsub.googleapis.com`)
   - For message queue and event publishing

## ✅ Created Resources

### Firestore Database
- **Name:** `(default)`
- **Type:** Firestore Native mode
- **Location:** `nam5` (US multi-region)
- **Database Edition:** Standard (Free tier)
- **Status:** Active
- **Collections:**
  - `cars` - Contains 5 car documents

### Artifact Registry Repository
- **Name:** `carinspectinator-services`
- **Format:** Docker
- **Location:** `europe-west1`
- **Description:** CarInspectinator microservices container registry
- **Status:** Active

## ✅ Authentication Setup

### Local Development
- **Method:** Application Default Credentials (ADC)
- **Command run:** `gcloud auth application-default login`
- **Credentials file:** `~/.config/gcloud/application_default_credentials.json`
- **Quota project:** `car-inspectinator-3000`

### GitHub Actions (CI/CD)
- **Method:** Workload Identity Federation
- **Service Account:** Set via `GCP_SERVICE_ACCOUNT` secret
- **Workload Identity Provider:** Set via `GCP_WORKLOAD_IDENTITY_PROVIDER` secret

## 📊 Firestore Data

### Cars Collection
Currently contains 5 car documents:

1. **Volkswagen Golf GTI** 
   - ID: `ab0b11f1-ce41-42f2-81ef-e4e564e4f8d7`
   
2. **BMW M3**
   - ID: `a350b538-8d62-4cba-9dcc-47031fc7f43f`
   
3. **Audi RS7**
   - ID: `38765da5-0633-4ae0-89d1-0dfe1766cd86`
   
4. **Mercedes G63**
   - ID: `8d658c73-e03d-44a8-bef7-d94d6197a4bb`
   
5. **Toyota Supra**
   - ID: `91c265af-7236-43b1-a07e-d9f0d184d0c2`

## 🔧 Workflow Updates

The GitHub Actions workflow (`.github/workflows/google-cloudrun-deploy-containers.yaml`) has been updated to:

1. **Enable required APIs automatically** before deployment
2. **Handle API enablement gracefully** without manual intervention
3. **Create Artifact Registry repository** if it doesn't exist

## 🚀 Deployment Configuration

### Region
- **Primary:** `europe-west1`

### Environment
- **Current:** `production` (deploys from `main` branch)

### Service Configuration
See `cloud/services.json` for detailed service configurations including:
- Memory allocation
- CPU allocation
- Min/max instances
- Timeout settings
- Environment variables
- Service accounts

## 📝 Next Steps for Future Services

When adding new services that use Firestore:

1. **No API enablement needed** - Already done! ✅
2. **Authentication works** - ADC is configured ✅
3. **Database exists** - Firestore is ready ✅

Just:
1. Create your service code
2. Add it to `services.json`
3. Push to `main` branch
4. GitHub Actions will deploy automatically

## 🔍 Useful Commands

### Check API Status
```bash
gcloud services list --enabled --project=car-inspectinator-3000
```

### View Firestore Data
```bash
# List collections
gcloud firestore collections list --project=car-inspectinator-3000

# Count documents in cars collection
gcloud firestore documents list \
  --collection-ids=cars \
  --project=car-inspectinator-3000 \
  --format="value(name)" | wc -l
```

### View Artifact Registry
```bash
# List repositories
gcloud artifacts repositories list \
  --location=europe-west1 \
  --project=car-inspectinator-3000

# List images in repository
gcloud artifacts docker images list \
  europe-west1-docker.pkg.dev/car-inspectinator-3000/carinspectinator-services \
  --project=car-inspectinator-3000
```

### View Cloud Run Services
```bash
# List services
gcloud run services list \
  --region=europe-west1 \
  --project=car-inspectinator-3000

# Get service details
gcloud run services describe car-service \
  --region=europe-west1 \
  --project=car-inspectinator-3000
```

## 🛡️ Security Notes

- **Firestore Rules:** Currently using default rules. Consider adding security rules for production.
- **Cloud Run Authentication:** HTTP services allow unauthenticated access (via `allUsers` IAM binding).
- **Service Accounts:** Each service should have its own service account with minimal permissions (principle of least privilege).

## 💰 Cost Monitoring

- **Firestore:** Free tier includes 1 GB storage, 50,000 reads/day, 20,000 writes/day
- **Cloud Run:** Free tier includes 2 million requests/month, 360,000 GB-seconds/month
- **Artifact Registry:** Free tier includes 0.5 GB storage/month

Monitor usage in [GCP Console → Billing](https://console.cloud.google.com/billing)

## 📚 Resources

- [Firestore Documentation](https://cloud.google.com/firestore/docs)
- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Artifact Registry Documentation](https://cloud.google.com/artifact-registry/docs)
- [Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)

