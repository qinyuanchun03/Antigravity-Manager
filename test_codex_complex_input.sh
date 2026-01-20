#!/bin/bash

# Test script for Codex complex input and developer role
# Usage: ./test_codex_complex_input.sh [API_KEY] [BASE_URL]

API_KEY=${1:-"sk-antigravity"}
BASE_URL=${2:-"http://127.0.0.1:8045"}

echo "--- Testing /v1/responses with complex input (messages array) ---"

curl -X POST "${BASE_URL}/v1/responses" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
  "model": "gpt-5.2-codex",
  "input": [
    {
      "role": "developer",
      "content": "You are a helpful assistant."
    },
    {
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": "hi, who are you?"
        }
      ]
    }
  ],
  "stream": true
}'

echo -e "\n\n--- Test Completed ---"
