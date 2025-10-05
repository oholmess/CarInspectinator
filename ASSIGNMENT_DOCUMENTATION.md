## Core Features Analysis

### Feature 1: RESTful API with CRUD Operations
**Backend API (`cloud/containers/car-service/`):**
- **CREATE**: Add new cars to Firestore
- **READ**: GET `/v1/cars` (all cars), GET `/v1/cars/{id}` (single car)
- **UPDATE**: Update car specifications
- **DELETE**: Remove cars from database
- **Technology**: FastAPI + Firestore + Google Cloud Run

### Feature 2: Cloud-Based 3D Model Storage & Delivery
- Google Cloud Storage integration for USDZ files
- Signed URL generation (24-hour expiration)
- Automatic model URL injection in API responses
- Client-side download & caching system
- 5 car models totaling 61.46 MB

### Feature 3: Vision Pro Native Application 
**Frontend Application:**
- Native VisionOS Swift application
- Real-time 3D model rendering with RealityKit
- Network service layer
- Local caching with ModelDownloader service
- Three-tier loading strategy (URL → Cache → Bundle)

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    CARINSPECTINATOR ARCHITECTURE                │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  CLIENT LAYER (VisionOS Swift App)                               │
├──────────────────────────────────────────────────────────────────┤
│ Views/                    │  Models/           │  Services/      │
│  - HomePageView           │  - Car             │  - CarService   │
│  - CarDetailedView        │  - AppModel        │  - Network      │
│  - CarVolumeView          │  - Specifications  │  - ModelDown    │
│  - ImmersiveView          │                    │    loader       │
│                           │                    │                 │
│  View Models/             │                    │                 │
│  - HomePageViewModel      │                    │                 │
│  - CarDetailedViewModel   │                    │                 │
└───────────────────────────┴────────────────────┴─────────────────┘
                            │
                            │ HTTPS/REST
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  API LAYER (FastAPI on Google Cloud Run)                         │
├──────────────────────────────────────────────────────────────────┤
│  Routes (routes.py)                                              │
│  ├─ GET  /v1/cars          → List all cars                       │
│  ├─ GET  /v1/cars/{id}     → Get single car                      │
│  ├─ POST /v1/cars          → Create car                          │
│  ├─ PUT  /v1/cars/{id}     → Update car                          │
│  └─ DELETE /v1/cars/{id}   → Delete car                          │
│                                                                  │
│  Services/                                                       │
│  ├─ get_cars.py     → Business logic for car retrieval           │
│  └─ get_car.py      → Business logic for single car              │
│                                                                  │
│  Repositories (repositories.py)                                  │
│  └─ Data access layer for Firestore operations                   │
│                                                                  │
│  Storage (storage.py)                                            │
│  └─ GCS signed URL generation                                    │
└──────────────────────────────────────────────────────────────────┘
                    │                           │
                    │ Firestore SDK             │ Cloud Storage API
                    ▼                           ▼
┌──────────────────────────────┐  ┌───────────────────────────────┐
│  FIRESTORE DATABASE          │  │  GOOGLE CLOUD STORAGE         │
├──────────────────────────────┤  ├───────────────────────────────┤
│  Collection: cars            │  │  Bucket:                      │
│  ├─ Document: {car_id}       │  │  carinspectinator-car-models  │
│  │  ├─ make: String          │  │                               │
│  │  ├─ model: String         │  │  models/                      │
│  │  ├─ year: Int             │  │  ├─ vw_golf_5_gti.usdz        │
│  │  ├─ volumeId: String      │  │  ├─ BMW_M4_f82.usdz           │
│  │  ├─ engine: Object        │  │  ├─ 2020_Audi_RS7_...usdz     │
│  │  ├─ performance: Object   │  │  ├─ 2020_Mercedes_...usdz     │
│  │  ├─ dimensions: Object    │  │  └─ Toyota_Supra.usdz         │
│  │  └─ drivetrain: Object    │  │                               │
└──────────────────────────────┘  └───────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  CI/CD LAYER (GitHub Actions)                                    │
├──────────────────────────────────────────────────────────────────┤
│  Workflow: google-cloudrun-deploy-containers.yaml                │
│  ├─ Trigger: Push to main branch                                 │
│  ├─ Build: Docker image with BuildKit                            │
│  ├─ Push: Artifact Registry (europe-west1)                       │
│  └─ Deploy: Cloud Run (auto-scaling 0-10 instances)              │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🔄 SDLC Model: **Agile/Iterative**

**Justification:**
1. **Iterative Development**:
   - Phase 1: Basic API with Firestore
   - Phase 2: Vision Pro frontend
   - Phase 3: Cloud storage for 3D models
   
2. **Continuous Integration**: GitHub Actions for automated deployment

3. **Incremental Features**: Each feature can be deployed independently

### SDLC Phases Documentation:

#### 1. **Planning Phase**
- **Goal**: Create a VisionOS app for interactive car inspection
- **Stakeholders**: 
  - End users (car enthusiasts, potential buyers)
  - Content creators (3D model artists)
  - System administrators
- **Timeline**: Phased rollout (Oct 2025)
- **Resources**: GCP infrastructure, VisionOS development environment

#### 2. **Requirements Phase**
**Functional Requirements:**
- FR1: System shall store and retrieve car data (CRUD)
- FR2: System shall provide RESTful API for car data
- FR3: System shall host 3D models in cloud storage
- FR4: System shall generate time-limited signed URLs (24h)
- FR5: Client shall download and cache 3D models
- FR6: Client shall display 3D models in VisionOS

**Non-Functional Requirements:**
- NFR1: API response time < 200ms (achieved via Cloud Run)
- NFR2: Support 0-10K concurrent users (auto-scaling)
- NFR3: 99.9% uptime (Cloud Run SLA)
- NFR4: Secure model access (signed URLs)
- NFR5: Cost-effective storage (~$4/month for 1K downloads)

#### 3. **Design Phase**
- **Architecture**: Microservices (API service, storage service)
- **Database Schema**: NoSQL (Firestore) for flexible car specifications
- **API Design**: RESTful with OpenAPI documentation
- **Security**: IAM roles, signed URLs, HTTPS only

#### 4. **Development Phase**
- **Backend**: Python FastAPI, containerized with Docker
- **Frontend**: Swift/SwiftUI for VisionOS
- **Infrastructure**: Terraform-ready, IaC principles
- **Version Control**: Git with feature branches

---

## 📝 UML Class Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        Car                                  │
├─────────────────────────────────────────────────────────────┤
│ - id: UUID                                                  │
│ - make: String                                              │
│ - model: String                                             │
│ - year: Optional[Int]                                       │
│ - volumeId: Optional[String]                                │
│ - modelUrl: Optional[String]                                │
│ - engine: Optional[Engine]                                  │
│ - performance: Optional[Performance]                        │
│ - dimensions: Optional[Dimensions]                          │
│ - drivetrain: Optional[Drivetrain]                          │
├─────────────────────────────────────────────────────────────┤
│ + to_dict(): Dict                                           │
│ + from_dict(data: Dict): Car                                │
└─────────────────────────────────────────────────────────────┘
            │
            │ composed of
            ├──────────────────────┬──────────────────────┐
            ▼                      ▼                      ▼
┌─────────────────────┐  ┌──────────────────┐  ┌─────────────────┐
│     Engine          │  │   Performance    │  │   Dimensions    │
├─────────────────────┤  ├──────────────────┤  ├─────────────────┤
│ - displacement      │  │ - horsepower     │  │ - wheelbase     │
│ - cylinders         │  │ - torque         │  │ - length        │
│ - configuration     │  │ - zeroToSixty    │  │ - width         │
│ - fuel              │  │ - topSpeed       │  │ - curbWeight    │
│ - induction         │  │ - epaCity        │  │ - fuelTank      │
└─────────────────────┘  └──────────────────┘  └─────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                   CarRepository                             │
├─────────────────────────────────────────────────────────────┤
│ - db: FirestoreClient                                       │
│ - storage: StorageService                                   │
├─────────────────────────────────────────────────────────────┤
│ + get_cars(): List[Car]                                     │
│ + get_car(car_id: String): Optional[Car]                    │
│ + create_car(car: Car): Boolean                             │
│ + update_car(car_id: String, car: Car): Boolean             │
│ + delete_car(car_id: String): Boolean                       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                   StorageService                            │
├─────────────────────────────────────────────────────────────┤
│ - bucket_name: String                                       │
│ - expiration_hours: Int                                     │
├─────────────────────────────────────────────────────────────┤
│ + get_model_url_for_volume_id(id: String): Optional[String] │
│ + generate_signed_url(blob: String): Optional[String]       │
│ + upload_model(path: String, id: String): Boolean           │
│ + model_exists(id: String): Boolean                         │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                   ModelDownloader                           │
├─────────────────────────────────────────────────────────────┤
│ - cacheDirectory: URL                                       │
│ - activeDownloads: Set[String]                              │
│ - downloadProgress: Dict[String, Double]                    │
├─────────────────────────────────────────────────────────────┤
│ + downloadModel(url: String, id: String): URL?              │
│ + isCached(id: String): Boolean                             │
│ + clearCache(id: String): Void                              │
│ + getCacheSize(): Double                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 DevOps & Scalability Reflection

### Current DevOps Practices

**1. CI/CD Pipeline**
- The projects GitHub Actions workflow automates:
  - Docker image building
  - Push to Artifact Registry
  - Deployment to Cloud Run
- Triggered on every push to main branch

**2. Infrastructure as Code (IaC) Ready**
- Configuration in `services.json`
- Reproducible deployments
- Environment variables for configuration

**3. Containerization**
- Docker for consistent environments
- Cloud Run for serverless auto-scaling

### How this app could be scaled

**1. Scaling (Already Implemented because of GCP integration)**
```
Current: 0-10 instances (auto-scale)
Recommendation: Increase to 0-100 for peak loads
Cost: Pay-per-request model
```

**2. Database Optimization**
```
Current: Firestore (NoSQL)
Scaling: 
- Add indexes for more common queries
- Implement caching layer (Redis/Memcached), although firebase does help with caching
- Consider Cloud SQL for relational data
```

**3. Admin view for adding new Cars and 3D Models**
```
Current: Nothing, manually uploading everything via gcloud CLI
Implementation: Could add an admin interface to automate adding new cars to the database for users to user
```

**4. Error Tracing**
```
Implement:
- Sentry for error logs and catches
- Metrics and performance monitoring
- Crash analysis


**5. Multi-Region Deployment**
```
Phase 1: europe-west1 (current)
Phase 2: Add us-central1
Phase 3: Global load balancer
Phase 4: Regional Firestore replication
```

## 📎  Appendices

1. `cloud/containers/car-service/app/main.py` - API entry point
2. `cloud/containers/car-service/app/storage.py` - GCS integration
3. `vision-pro/CarInspectinator/Services/ModelDownloader.swift` - Caching logic
4. Key snippets from `repositories.py` showing CRUD operations

---

##  Use of AI

1. Frontend: Because I am versed in SwiftUI, AI was only used to help build the base Car schema, and handling 3D model logic, as I'm unfamiliar with the RealityKit SwiftUI Library.
2. Backend: Other than the main car schema, AI did not write any code on the backend for FastAP
3. Scripts: Claude helped write scripts to setup some GCP services and test locally with uvicorn
4. Documenation: Claude has helped organize and improve the documentation for the project. I created rough outlines and received help in organization and aided in the creation of clear and consise diagrams. Claude also helped create the README file.

