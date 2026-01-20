#!/bin/bash

# Configuration
API_KEY="sk-79754f1fecab4451aa8bb9f0ba4d5ee9"
BASE_URL="http://127.0.0.1:8045"
MODEL="gemini-2.5-flash"

echo "==========================================="
echo "Testing OpenAI Protocol Endpoints"
echo "Model: $MODEL"
echo "==========================================="

# 1. Chat Completions
echo -e "\n[Test 1] POST /v1/chat/completions (Non-stream)"
curl -s -v -X POST "$BASE_URL/v1/chat/completions" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$MODEL\",
    \"messages\": [{\"role\": \"user\", \"content\": \"Say 'Chat Test Success'\"}],
    \"stream\": false
  }" 2>&1 | grep -E "HTTP/1.1|x-mapped-model|x-account-email|Chat Test Success"

# 2. Legacy Completions
echo -e "\n[Test 2] POST /v1/completions (Non-stream)"
curl -s -v -X POST "$BASE_URL/v1/completions" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$MODEL\",
    \"prompt\": \"Say 'Legacy Test Success'\",
    \"stream\": false
  }" 2>&1 | grep -E "HTTP/1.1|x-mapped-model|x-account-email|Legacy Test Success"

# 3. Responses (Codex Alias)
echo -e "\n[Test 3] POST /v1/responses (Non-stream)"
curl -s -v -X POST "$BASE_URL/v1/responses" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$MODEL\",
    \"prompt\": \"Say 'Responses Test Success'\",
    \"stream\": false
  }" 2>&1 | grep -E "HTTP/1.1|x-mapped-model|x-account-email|Responses Test Success"

echo -e "\n==========================================="
echo "Regression Testing Complete"
echo "==========================================="
