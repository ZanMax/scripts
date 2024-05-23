#!/bin/bash

# Check if the model name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <model_name>"
  exit 1
fi

MODEL_NAME=$1

# Pull the specified model
ollama pull $MODEL_NAME

# List all models
ollama list