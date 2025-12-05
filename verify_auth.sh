#!/bin/bash

# verify_auth.sh
# Usage: ./verify_auth.sh <TOKEN>

TOKEN=$1

if [ -z "$TOKEN" ]; then
  echo "Usage: $0 <TOKEN>"
  echo "Please provide a valid Bearer token from Authentik."
  exit 1
fi

echo "Testing Rust Endpoint..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $TOKEN" http://localhost:9004/protected)

if [ "$RESPONSE" == "200" ]; then
  echo "✅ Rust Auth Success (200 OK)"
else
  echo "❌ Rust Auth Failed (Status: $RESPONSE)"
fi

echo "Testing Rust Endpoint without Token..."
RESPONSE_NO_AUTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9004/protected)

if [ "$RESPONSE_NO_AUTH" == "401" ]; then
  echo "✅ Rust No-Auth Success (401 Unauthorized)"
else
  echo "❌ Rust No-Auth Failed (Status: $RESPONSE_NO_AUTH)"
fi
