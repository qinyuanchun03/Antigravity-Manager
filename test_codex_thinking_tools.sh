#!/bin/bash

# Test script for Codex Custom Tool and Claude Thinking requirement
# Usage: ./test_codex_thinking_tools.sh [API_KEY] [BASE_URL]

API_KEY=${1:-"sk-antigravity"}
BASE_URL=${2:-"http://127.0.0.1:8045"}

echo "--- Testing /v1/responses with apply_patch (Custom Tool) and Thinking ---"

curl -i -X POST "${BASE_URL}/v1/responses" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
  "model": "gpt-5.2-codex",
  "input": [
    {
      "role": "user",
      "content": "Apply this patch to main.rs"
    },
    {
      "role": "assistant",
      "content": "Certainly, I will apply the patch."
    },
    {
      "role": "user",
      "content": "Do it now."
    }
  ],
  "tools": [
    {
      "type": "custom",
      "name": "apply_patch",
      "description": "Applies a patch",
      "format": { "type": "grammar", "syntax": "lark", "definition": "..." }
    }
  ],
  "stream": true
}'

echo -e "\n\n--- Test Completed ---"
