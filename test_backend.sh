#!/bin/bash

# Backend API Testing Script
# Make sure the backend is running before executing this script

BASE_URL="http://localhost:8080/api"
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Healthcare Appointment API Test Script"
echo "=========================================="
echo ""

# Test 1: Register a new user
echo "Test 1: Registering new user..."
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser'$(date +%s)'",
    "password": "password123",
    "email": "test'$(date +%s)'@example.com",
    "firstName": "Test",
    "lastName": "User"
  }')

if echo "$REGISTER_RESPONSE" | grep -q "token"; then
  echo -e "${GREEN}✓ Registration successful${NC}"
  TOKEN=$(echo "$REGISTER_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
  echo "Token: ${TOKEN:0:50}..."
else
  echo -e "${RED}✗ Registration failed${NC}"
  echo "Response: $REGISTER_RESPONSE"
  exit 1
fi

echo ""

# Test 2: Login with existing user
echo "Test 2: Logging in with patient1..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "patient1",
    "password": "password123"
  }')

if echo "$LOGIN_RESPONSE" | grep -q "token"; then
  echo -e "${GREEN}✓ Login successful${NC}"
  TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
  echo "Token: ${TOKEN:0:50}..."
else
  echo -e "${RED}✗ Login failed${NC}"
  echo "Response: $LOGIN_RESPONSE"
  exit 1
fi

echo ""

# Test 3: Get appointments (should be empty or show existing)
echo "Test 3: Getting user appointments..."
APPOINTMENTS=$(curl -s -X GET "$BASE_URL/appointments" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json")

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Retrieved appointments successfully${NC}"
  echo "Appointments: $APPOINTMENTS"
else
  echo -e "${RED}✗ Failed to retrieve appointments${NC}"
fi

echo ""

# Test 4: Create an appointment
echo "Test 4: Creating a new appointment..."
FUTURE_DATE=$(date -u -v+7d +"%Y-%m-%dT%H:%M:%S" 2>/dev/null || date -u -d "+7 days" +"%Y-%m-%dT%H:%M:%S" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S")

CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/appointments" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"doctorName\": \"Dr. Test\",
    \"appointmentDateTime\": \"$FUTURE_DATE\",
    \"reason\": \"Test appointment\"
  }")

if echo "$CREATE_RESPONSE" | grep -q "id"; then
  echo -e "${GREEN}✓ Appointment created successfully${NC}"
  APPOINTMENT_ID=$(echo "$CREATE_RESPONSE" | grep -o '"id":[0-9]*' | cut -d':' -f2)
  echo "Appointment ID: $APPOINTMENT_ID"
else
  echo -e "${RED}✗ Failed to create appointment${NC}"
  echo "Response: $CREATE_RESPONSE"
fi

echo ""

# Test 5: Test unauthorized access
echo "Test 5: Testing unauthorized access (should fail)..."
UNAUTHORIZED=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/appointments" \
  -H "Content-Type: application/json")

HTTP_CODE=$(echo "$UNAUTHORIZED" | tail -n1)
if [ "$HTTP_CODE" = "401" ] || [ "$HTTP_CODE" = "403" ]; then
  echo -e "${GREEN}✓ Unauthorized access correctly rejected (HTTP $HTTP_CODE)${NC}"
else
  echo -e "${RED}✗ Security issue: Unauthorized request not rejected${NC}"
fi

echo ""
echo "=========================================="
echo "Testing complete!"
echo "=========================================="

