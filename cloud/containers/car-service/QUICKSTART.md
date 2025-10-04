# Quick Start Guide - Firebase Integration

## 🚀 Quick Setup (5 minutes)

### 1. Get Firebase Credentials
```bash
# Set your service account key path
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your-service-account-key.json"
```

### 2. Seed Firestore
```bash
cd cloud/containers/car-service
python seed_firestore.py
```

Expected output:
```
✓ Added Volkswagen Golf GTI
✓ Added BMW M3
✓ Added Audi RS7
✓ Added Mercedes G63
✓ Added Toyota Supra
Seeding complete! 5/5 cars added successfully
```

### 3. Start the Service
```bash
uvicorn app.main:app --reload --port 8000
```

### 4. Test the API
```bash
# Option 1: Use the test script
./test_api.sh

# Option 2: Manual testing
curl http://localhost:8000/v1/cars | python3 -m json.tool
```

## 📁 What Changed

### New Files
- ✨ `app/firebase.py` - Firebase initialization
- ✨ `seed_firestore.py` - Script to populate Firestore
- ✨ `test_api.sh` - API testing script
- 📝 `FIREBASE_SETUP.md` - Detailed setup guide

### Modified Files
- ✏️ `app/repositories.py` - Now uses Firestore instead of in-memory DB
- ✏️ `app/main.py` - Initializes Firebase on startup
- ✏️ `app/schemas.py` - Deprecated in-memory DB

### Unchanged (Repository Pattern FTW!)
- ✅ `app/services/get_car.py` - No changes needed
- ✅ `app/services/get_cars.py` - No changes needed
- ✅ `app/routes.py` - No changes needed

## 🔧 How It Works

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │ HTTP Request
       ▼
┌─────────────┐
│   routes.py │  (FastAPI endpoints)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ services/   │  (Business logic)
│ get_car.py  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│repositories │  (Data access - NOW USES FIRESTORE!)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Firestore  │  (Cloud database)
│ Collection: │
│   "cars"    │
└─────────────┘
```

## 📊 Firestore Structure

Collection: `cars`

Document ID: `{UUID}` (e.g., `123e4567-e89b-12d3-a456-426614174000`)

Document Fields:
```javascript
{
  make: "BMW",
  model: "M3",
  year: 2020,
  bodyStyle: "Sedan",
  iconAssetName: "bmw_m3",
  volumeId: "BMW_M4_f82",
  engine: {
    displacement: { value: 3.0, unit: "liters" },
    cylinders: 6,
    configuration: "I6",
    fuel: "gasoline",
    induction: "turbocharged",
    code: "S58"
  },
  performance: { ... },
  dimensions: { ... },
  drivetrain: { ... },
  otherSpecs: { ... }
}
```

## 🎯 Available Cars

After seeding, you'll have 5 cars:

1. **Volkswagen Golf GTI** (2020) - 1.8L Turbo I4, 330 hp
2. **BMW M3** (2020) - 3.0L Twin-Turbo I6, 473 hp
3. **Audi RS7** (2020) - 4.0L Twin-Turbo V8, 591 hp
4. **Mercedes G63** (2020) - 4.0L Twin-Turbo V8, 577 hp
5. **Toyota Supra** (2020) - 3.0L Turbo I6, 335 hp

## 🌐 API Endpoints

### Get All Cars
```bash
GET /v1/cars
```

Response: Array of all cars

### Get Single Car
```bash
GET /v1/cars/{carId}
```

Response: Single car object

### Health Check
```bash
GET /health
```

Response: `{ "status": "ok", "service": "car-service" }`

## 🔍 Troubleshooting

### "Failed to initialize Firebase"
```bash
# Check your credentials
echo $GOOGLE_APPLICATION_CREDENTIALS

# Verify file exists
ls -l $GOOGLE_APPLICATION_CREDENTIALS
```

### Empty response from /v1/cars
```bash
# Re-run the seed script
python seed_firestore.py
```

### Port already in use
```bash
# Use a different port
uvicorn app.main:app --reload --port 8001
```

## 📚 More Information

For detailed setup instructions, see `FIREBASE_SETUP.md`

## 🚀 Deploy to Google Cloud Run

```bash
# Deploy directly from source
gcloud run deploy car-service \
  --source . \
  --region us-central1 \
  --allow-unauthenticated \
  --platform managed
```

The service will automatically use GCP credentials when deployed.

