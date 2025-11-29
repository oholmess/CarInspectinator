# 3D Car Models on Google Cloud Storage

This guide explains how to host and serve car 3D models (USDZ files) from Google Cloud Storage.

## Architecture Overview

```
┌──────────────┐         ┌───────────────┐         ┌──────────────────┐
│ Vision Pro   │────1───>│ Backend API   │────2───>│ Google Cloud     │
│ App          │         │ (car-service) │         │ Storage          │
│              │<───4────│               │<───3────│ (USDZ files)     │
└──────────────┘         └───────────────┘         └──────────────────┘
       │                                                      │
       │ 5. Download model directly                          │
       └─────────────────────────────────────────────────────┘
```

**Flow:**
1. App fetches car data from API
2. Backend generates signed URL for 3D model (expires in 24 hours)
3. Backend returns car data with `modelUrl` field
4. App receives car data
5. App downloads USDZ file directly from GCS (bypassing backend)
6. App caches model locally for performance

**Benefits:**
- ✅ Large files don't go through backend
- ✅ Backend controls access via signed URLs
- ✅ Easy to add new models without app updates
- ✅ Models are cached locally for performance
- ✅ Backward compatible with bundled models

## Setup Instructions

### 1. Create GCS Bucket

Run the setup script to create and configure the bucket:

```bash
cd cloud/containers/car-service
python3 setup_gcs_bucket.py
```

This creates:
- Bucket: `carinspectinator-car-models`
- Region: `europe-west1`
- CORS policy for direct downloads
- Proper IAM permissions

### 2. Upload 3D Models

Upload your USDZ files to the bucket:

```bash
python3 upload_models.py
```

**Model File Structure:**
```
gs://carinspectinator-car-models/
  └── models/
      ├── vw_golf_5_gti.usdz
      ├── BMW_M4_f82.usdz
      ├── 2020_Audi_RS7_Sportback.usdz
      ├── 2020_Mercedes-Benz_G-Class_AMG_G63.usdz
      └── Toyota_Supra.usdz
```

**Naming Convention:** Models are named using their `volumeId` from the Car object.

### 3. Grant Permissions

The backend service account needs access to read and generate signed URLs:

```bash
# Grant storage permissions
gcloud projects add-iam-policy-binding car-inspectinator-3000 \
  --member="serviceAccount:backend-service@car-inspectinator-3000.iam.gserviceaccount.com" \
  --role="roles/storage.objectViewer"

# Grant permission to create signed URLs
gcloud projects add-iam-policy-binding car-inspectinator-3000 \
  --member="serviceAccount:backend-service@car-inspectinator-3000.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountTokenCreator"
```

### 4. Deploy Backend Changes

The backend is already configured with the necessary environment variables in `services.json`:

```json
{
  "environment_variables": {
    "STORAGE_BUCKET": "carinspectinator-car-models",
    "MODEL_URL_EXPIRATION_HOURS": "24"
  }
}
```

Deploy the updated service:

```bash
git add .
git commit -m "Add GCS support for 3D car models"
git push origin main
```

The GitHub Actions workflow will automatically deploy the changes.

## How It Works

### Backend Implementation

#### 1. Car Schema
The `Car` model now includes a `modelUrl` field:

```python
class Car(BaseModel):
    ...
    volumeId: Optional[str] = None
    modelUrl: Optional[str] = None  # Signed GCS URL
    ...
```

#### 2. Storage Utility (`app/storage.py`)
Handles GCS operations:

```python
# Generate signed URL for a model
def get_model_url_for_volume_id(volume_id: str) -> Optional[str]:
    blob_name = f"models/{volume_id}.usdz"
    return generate_signed_url(blob_name)
```

#### 3. Repository Layer
Automatically adds signed URLs when fetching cars:

```python
def get_car(car_id: str) -> Optional[Car]:
    ...
    car = Car(**car_data)
    
    # Generate signed URL if volumeId exists
    if car.volumeId and not car.modelUrl:
        car.modelUrl = get_model_url_for_volume_id(car.volumeId)
    
    return car
```

### Vision Pro App Implementation

#### 1. Car Model
Updated to include `modelUrl`:

```swift
struct Car: Codable {
    ...
    let volumeId: String?
    let modelUrl: String?  // Signed GCS URL
    ...
}
```

#### 2. ModelDownloader Service
Handles downloading and caching:

```swift
class ModelDownloader {
    func downloadModel(from urlString: String, volumeId: String) async throws -> URL?
    func isCached(volumeId: String) -> Bool
    func clearCache(for volumeId: String)
}
```

#### 3. CarVolumeView
Loads models with fallback priority:

1. **Download from URL** (if `modelUrl` is available)
2. **Load from cache** (if previously downloaded)
3. **Load from bundle** (backward compatibility)

```swift
// Priority 1: Load from URL
if let modelUrl = car.modelUrl {
    let localURL = try await downloadModel(from: modelUrl)
    modelEntity = try await loadModelFromFile(url: localURL)
}

// Priority 2: Load from cache
if downloader.isCached(volumeId: volumeId) {
    let cachedURL = downloader.cacheURL(for: volumeId)
    modelEntity = try await loadModelFromFile(url: cachedURL)
}

// Priority 3: Load from bundle
modelEntity = try await loadModelFromBundle(named: volumeId)
```

## Adding New Car Models

### 1. Prepare the USDZ File
Ensure your 3D model is in USDZ format optimized for Vision Pro.

### 2. Upload to GCS
You can upload manually or use the script:

**Manual Upload:**
```bash
gsutil cp my_model.usdz gs://carinspectinator-car-models/models/my_model.usdz
gsutil setmeta -h "Content-Type:model/vnd.usdz+zip" gs://carinspectinator-car-models/models/my_model.usdz
```

**Using Script:**
Add the model to `upload_models.py` and run:
```bash
python3 upload_models.py
```

### 3. Add Car to Database
Update `seed_firestore.py` with the new car, using the filename (without extension) as the `volumeId`:

```python
new_car = Car(
    make="Tesla",
    model="Model S",
    volumeId="2024_Tesla_Model_S",  # Must match filename
    ...
)
```

### 4. Run Seed Script
```bash
python3 seed_firestore.py
```

The backend will automatically generate signed URLs for the new model.

## Testing

### Test Backend API
```bash
# Get all cars (should include modelUrl fields)
curl https://car-service-xxx.run.app/v1/cars | jq '.[0].modelUrl'

# Get specific car
curl https://car-service-xxx.run.app/v1/cars/{car-id} | jq '.modelUrl'
```

### Test Model Download
```bash
# Copy a signed URL from the API response
MODEL_URL="https://storage.googleapis.com/..."

# Download the model
curl -o test_model.usdz "$MODEL_URL"

# Check file size
ls -lh test_model.usdz
```

### Test Vision Pro App
1. Run the app
2. Select a car
3. Open 3D view
4. Check console logs:
   - `"Loading model from URL: ..."` - Downloading
   - `"Loading model from cache: ..."` - Using cached
   - `"Loading model from bundle: ..."` - Fallback

## Troubleshooting

### ❌ Model URL is null
**Cause:** Model file doesn't exist in GCS or volumeId is incorrect

**Solution:**
```bash
# Check if file exists
gsutil ls gs://carinspectinator-car-models/models/

# Upload missing model
gsutil cp path/to/model.usdz gs://carinspectinator-car-models/models/{volumeId}.usdz
```

### ❌ 403 Forbidden when downloading
**Cause:** Signed URL expired or insufficient permissions

**Solution:**
- Signed URLs expire after 24 hours (fetch fresh car data)
- Check service account has `roles/iam.serviceAccountTokenCreator`

### ❌ App shows "Failed to load model"
**Cause:** Network error or invalid USDZ file

**Solution:**
- Check internet connection
- Verify USDZ file is valid and optimized for Vision Pro
- Check console logs for detailed error messages

### ❌ Backend can't generate signed URLs
**Cause:** Missing IAM permissions

**Solution:**
```bash
gcloud projects add-iam-policy-binding car-inspectinator-3000 \
  --member="serviceAccount:backend-service@car-inspectinator-3000.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountTokenCreator"
```

## Performance Optimization

### Model File Size
- Keep USDZ files under 50MB for better download experience
- Use texture compression
- Reduce polygon count where possible

### Caching
Models are automatically cached after first download:
- Cache location: `~/Library/Caches/CarModels/`
- Cache persists between app launches
- Clear cache via ModelDownloader if needed

### Signed URL Expiration
- Default: 24 hours
- Adjust via `MODEL_URL_EXPIRATION_HOURS` environment variable
- Shorter = more secure, but requires more frequent API calls
- Longer = better performance, but less secure

## Cost Estimation

### Google Cloud Storage Costs
- Storage: ~$0.02/GB per month (Europe region)
- Network egress: ~$0.12/GB (to internet)
- Operations: Negligible

**Example:**
- 10 car models × 30MB each = 300MB = $0.006/month storage
- 1000 downloads/month × 30MB = 30GB = $3.60/month egress

**Total: ~$3.61/month for 1000 downloads**

### Optimization Tips
- Use Cloud CDN for frequently accessed models (reduces egress costs)
- Implement cache headers (models rarely change)
- Consider bucket lifecycle policies for cleanup

## Security Considerations

### Signed URLs
- Time-limited (24 hours by default)
- No GCS credentials exposed to clients
- Can only download, not upload or delete

### Access Control
- Backend service account has minimal permissions
- Vision Pro app can only access via signed URLs
- CORS policy restricts cross-origin access

### Best Practices
- Keep signed URL expiration short
- Don't log or expose signed URLs
- Rotate service account keys regularly
- Monitor unusual download patterns

## Future Enhancements

### Potential Improvements
- [ ] Add variant models (different colors, configurations)
- [ ] Implement progressive download for large models
- [ ] Add model version management
- [ ] Support additional formats (GLB, FBX)
- [ ] Add model metadata (author, license, etc.)
- [ ] Implement Cloud CDN for better performance
- [ ] Add analytics for popular models

## Resources

- [Google Cloud Storage Documentation](https://cloud.google.com/storage/docs)
- [Signed URLs Guide](https://cloud.google.com/storage/docs/access-control/signed-urls)
- [USDZ Best Practices](https://developer.apple.com/augmented-reality/quick-look/)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)

