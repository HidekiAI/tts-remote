#!/bin/bash
source .env.local

# Your API key
API_KEY="${_HUGGING_FACE_API_KEY_}"

# BERT: 
MODEL_URL="https://api-inference.huggingface.co/models/bert-base-uncased"

# DistilBERT: 
MODEL_URL="https://api-inference.huggingface.co/models/distilbert-base-uncased"

# T5: 
MODEL_URL="https://api-inference.huggingface.co/models/t5-small"

# GPT-2: 
MODEL_URL="https://api-inference.huggingface.co/models/gpt2"


# google/madlad400-10b-mt
MODEL_URL="https://api-inference.huggingface.co/models/google/madlad400-10b-mt"

MODEL_URL="https://api-inference.huggingface.co/models/google-t5/t5-large"

MODEL_URL="https://api-inference.huggingface.co/models/google/flan-t5-large"

MODEL_URL="https://api-inference.huggingface.co/models/timpal0l/mdeberta-v3-base-squad2"

#MODEL_URL="https://api-inference.huggingface.co/models/KoichiYasuoka/bert-base-japanese-wikipedia-ud-head"


# from transformers import AutoTokenizer,AutoModelForQuestionAnswering,QuestionAnsweringPipeline
# tokenizer=AutoTokenizer.from_pretrained("KoichiYasuoka/bert-base-japanese-wikipedia-ud-head")
# model=AutoModelForQuestionAnswering.from_pretrained("KoichiYasuoka/bert-base-japanese-wikipedia-ud-head")
# qap=QuestionAnsweringPipeline(tokenizer=tokenizer,model=model,align_to_words=False)
# print(qap(question="国語",context="全学年にわたって小学校の国語の教科書に挿し絵が用いられている"))





# Set your question and context
QUESTION="国語"
CONTEXT="全学年にわたって小学校の国語の教科書に挿し絵が用いられている"




QUESTION="小学校の国語の教科書に挿し絵が用いられていることはどのように説明されていますか?"
CONTEXT="全学年にわたって小学校の国語の教科書に挿し絵が用いられている"

QUESTION="国語"
CONTEXT="小学校の国語の教科書に挿し絵が用いられていることはどのように説明されていますか?"


# Data to be sent to the model
DATA='{ 
          "inputs": {
            "question": "'"$QUESTION"'",
            "context": "'"$CONTEXT"'" }
      }'

# Make the API request using cURL
echo "Using model: '${MODEL_URL}'"
response=$(curl -s -X POST "$MODEL_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "$DATA" )

# Print the response
echo "$response" | json_pp


# Extract the confidence score and answer from the response
score=$(echo "$response" | jq -r '.score')
answer=$(echo "$response" | jq -r '.answer')

# Check if the score is below a threshold and handle accordingly
if (( $(echo "$score < 0.5" | bc -l) )); then
    echo "Low confidence in the answer. Please try again or rephrase the question."
else
    echo "Answer: $answer"
    echo "Confidence Score: $score"
fi

