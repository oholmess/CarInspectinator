#!/bin/bash
# Script to test the Car Service API

BASE_URL="${BASE_URL:-http://localhost:8000}"

echo "================================"
echo "Car Service API Test Script"
echo "================================"
echo ""

# Test health endpoint
echo "1. Testing health endpoint..."
curl -s "${BASE_URL}/health" | python3 -m json.tool
echo -e "\n"

# Test get all cars
echo "2. Getting all cars..."
response=$(curl -s "${BASE_URL}/v1/cars")
echo "$response" | python3 -m json.tool
echo -e "\n"

# Extract first car ID
car_id=$(echo "$response" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data[0]['id'] if data else '')" 2>/dev/null)

if [ -n "$car_id" ]; then
    echo "3. Getting specific car (ID: $car_id)..."
    curl -s "${BASE_URL}/v1/cars/${car_id}" | python3 -m json.tool
    echo -e "\n"
else
    echo "3. No cars found. Run 'python seed_firestore.py' to populate Firestore."
    echo -e "\n"
fi

echo "================================"
echo "API testing complete!"
echo "================================"

