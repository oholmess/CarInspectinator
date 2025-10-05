# CarInspectinator

A VisionOS application for interactive 3D car inspection with cloud-based model storage.

## Features

- 🚗 Browse comprehensive car specifications
- 🔍 View detailed car information (engine, performance, dimensions)
- 🎯 Interactive 3D car models in augmented reality
- ☁️ Cloud-based model storage with on-demand loading
- 💾 Smart caching for instant subsequent loads
- 🔒 Secure access via time-limited signed URLs

## Architecture

- **Frontend**: Native VisionOS app (Swift/SwiftUI + RealityKit)
- **Backend**: FastAPI microservice on Google Cloud Run
- **Database**: Google Firestore (NoSQL)
- **Storage**: Google Cloud Storage for 3D models (USDZ format)
- **CI/CD**: GitHub Actions with automated deployment

## Prerequisites

### Backend Setup
- Python 3.11+
- Google Cloud SDK
- GCP Project with billing enabled
- Docker (for local containerization)

### Frontend Setup
- macOS 14+ (Sonoma)
- Xcode 15+
- VisionOS SDK
- Apple Developer account (for device deployment)

## Frontend Setup Instructions

### 1. Open Xcode Project
\`\`\`bash
cd vision-pro
open CarInspectinator.xcodeproj
\`\`\`

### 2. Configure API Endpoint
Update `NetworkRoutes.swift` with your Cloud Run URL:
\`\`\`swift
static let baseURL = "https://car-service-xxx.run.app"
\`\`\`

### 3. Build and Run
1. Select VisionOS Simulator or device
2. Click Run (⌘R)
3. Grant necessary permissions when prompted

## API Documentation

Once deployed, visit:
- Interactive docs: `https://your-service.run.app/docs`
- OpenAPI spec: `https://your-service.run.app/openapi.json`

### Key Endpoints

#### GET /v1/cars
Returns list of all cars with signed model URLs.

\`\`\`json
[
  {
    "id": "uuid",
    "make": "BMW",
    "model": "M4",
    "year": 2020,
    "volumeId": "BMW_M4_f82",
    "modelUrl": "https://storage.googleapis.com/...",
    "engine": {...},
    "performance": {...}
  }
]
\`\`\`

#### GET /v1/cars/{car_id}
Returns single car by ID.

## Testing

### Backend API Tests
\`\`\`bash
cd cloud/containers/car-service
./test_api.sh
\`\`\`

### Frontend Tests
\`\`\`bash
cd vision-pro
xcodebuild test -scheme CarInspectinator -destination 'platform=visionOS Simulator'
\`\`\`

## Project Structure

\`\`\`
CarInspectinator/
├── cloud/
│   └── containers/
│       └── car-service/
│           ├── app/
│           │   ├── main.py           # FastAPI app
│           │   ├── routes.py         # API endpoints
│           │   ├── schemas.py        # Pydantic models
│           │   ├── repositories.py   # Data access layer
│           │   ├── storage.py        # GCS utilities
│           │   └── services/         # Business logic
│           ├── Dockerfile
│           ├── requirements.txt
│           ├── seed_firestore.py
│           └── setup_gcs_bucket.py
├── vision-pro/
│   └── CarInspectinator/
│       ├── App/                      # App entry point
│       ├── Models/                   # Data models
│       ├── Views/                    # UI components
│       ├── Services/                 # Network & caching
│       └── View Models/              # Business logic
└── .github/
    └── workflows/
        └── google-cloudrun-deploy-containers.yaml
\`\`\`

## Cost Estimation

### Monthly Costs (estimated for 1,000 downloads/month):
- Cloud Run: ~$0 (generous free tier)
- Firestore: ~$0 (small dataset)
- Cloud Storage: ~$0.01 (storage)
- Network Egress: ~$7.40 (downloads)
- **Total: ~$7.50/month**

## Troubleshooting

See `cloud/containers/car-service/TROUBLESHOOTING.md` for common issues and solutions.

## License

MIT License

## Author

[Your Name]