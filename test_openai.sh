#!/bin/bash

source .env.local

echo "Using API key: '${_OAI_KEY_FROM_ENV_}'"

curl https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${_OAI_KEY_FROM_ENV_}" \
  -d '{
     "model": "gpt-4o-mini",
     "messages": [{"role": "user", "content": "Say this is a test!"}],
     "temperature": 0.7
   }'
