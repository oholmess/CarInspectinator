# Firebase Firestore Setup for Car Service

This guide explains how to set up and use Firebase Firestore for the Car Service API.

## Prerequisites

1. **Firebase Project**
   - Create a Firebase project at [https://console.firebase.google.com](https://console.firebase.google.com)
   - Enable Firestore Database in your project

2. **Service Account Credentials**
   - Go to Project Settings > Service Accounts
   - Click "Generate New Private Key"
   - Save the JSON file securely (e.g., `service-account-key.json`)

## Local Development Setup

### 1. Set Environment Variable

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/service-account-key.json"
```

Or add to your `.env` file:
```
GOOGLE_APPLICATION_CREDENTIALS=/path/to/your/service-account-key.json
```

### 2. Install Dependencies

```bash
cd cloud/containers/car-service
pip install -r requirements.txt
```

### 3. Seed Firestore with Car Data

Run the seed script to populate Firestore with all 5 cars:

```bash
python seed_firestore.py
```

Expected output:
```
INFO:__main__:Initializing Firebase...
INFO:app.firebase:Firebase initialized with service account: /path/to/key.json
INFO:__main__:Creating car data...
INFO:__main__:Seeding 5 cars to Firestore...
INFO:__main__:✓ Added Volkswagen Golf GTI (ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
INFO:__main__:✓ Added BMW M3 (ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
INFO:__main__:✓ Added Audi RS7 (ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
INFO:__main__:✓ Added Mercedes G63 (ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
INFO:__main__:✓ Added Toyota Supra (ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
INFO:__main__:Seeding complete! 5/5 cars added successfully
```

### 4. Run the Service

```bash
# From the car-service directory
uvicorn app.main:app --reload --port 8000
```

Or use the provided shell script:
```bash
cd ../../  # Navigate to cloud directory
./python-uvicorn-test-service-local.sh
```

### 5. Test the API

Get all cars:
```bash
curl http://localhost:8000/v1/cars
```

Get a specific car (replace with actual UUID from seed output):
```bash
curl http://localhost:8000/v1/cars/{car-uuid}
```

## Google Cloud Platform Deployment

When deployed to GCP (Cloud Run), the service will automatically use Application Default Credentials. No need to set `GOOGLE_APPLICATION_CREDENTIALS`.

### Deploy to Cloud Run

```bash
gcloud run deploy car-service \
  --source . \
  --region us-central1 \
  --allow-unauthenticated
```

The Firestore client will automatically authenticate using the default service account.

## Firestore Collection Structure

### Collection: `cars`

Each document has the following structure:

```json
{
  "make": "BMW",
  "model": "M3",
  "year": 2020,
  "bodyStyle": "Sedan",
  "iconAssetName": "bmw_m3",
  "volumeId": "BMW_M4_f82",
  "engine": {
    "displacement": {
      "value": 3.0,
      "unit": "liters"
    },
    "cylinders": 6,
    "configuration": "I6",
    "fuel": "gasoline",
    "induction": "turbocharged",
    "code": "S58"
  },
  "performance": {
    "horsepower": {
      "value": 473,
      "unit": "horsepower"
    },
    "torque": {
      "value": 406,
      "unit": "poundForceFeet"
    },
    "zeroToSixty": {
      "value": 4.1,
      "unit": "seconds"
    },
    "topSpeed": {
      "value": 155,
      "unit": "milesPerHour"
    }
  },
  "dimensions": { ... },
  "drivetrain": { ... },
  "otherSpecs": { ... }
}
```

The document ID is the car's UUID (as a string).

## API Endpoints

### GET `/v1/cars`
Returns all cars from Firestore.

**Response:** `200 OK`
```json
[
  {
    "id": "uuid-string",
    "make": "BMW",
    "model": "M3",
    ...
  }
]
```

### GET `/v1/cars/{carId}`
Returns a specific car by UUID.

**Response:** `200 OK`
```json
{
  "id": "uuid-string",
  "make": "BMW",
  "model": "M3",
  ...
}
```

**Error Response:** `404 Not Found` if car doesn't exist

## Troubleshooting

### Error: "Failed to initialize Firebase"
- Check that `GOOGLE_APPLICATION_CREDENTIALS` is set correctly
- Verify the service account key file exists and is valid
- Ensure the service account has Firestore permissions

### Error: "Car not found"
- Run the seed script to populate Firestore
- Verify the UUID is correct
- Check Firestore console to see if documents exist

### Empty response from GET /v1/cars
- Run the seed script: `python seed_firestore.py`
- Check Firestore console to verify documents were created

## Files Modified

- `app/firebase.py` - Firebase initialization
- `app/repositories.py` - Firestore CRUD operations
- `app/main.py` - Firebase startup initialization
- `seed_firestore.py` - Script to seed Firestore
- `app/services/get_car.py` - ✅ No changes needed
- `app/services/get_cars.py` - ✅ No changes needed

The service layer (`get_car.py` and `get_cars.py`) doesn't need changes because it uses the repository pattern, which now points to Firestore instead of the in-memory database.

