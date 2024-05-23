#!/bin/bash

# Check if the model name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <model_name>"
  exit 1
fi

MODEL_NAME=$1

# Execute the script on multiple remote hosts
ssh user@10.0.0.100 "bash ~/ollama_pull.sh $MODEL_NAME"
echo -e "----\n"

ssh user@10.0.0.101 "bash ~/ollama_pull.sh $MODEL_NAME"
echo -e "----\n"

ssh user@10.0.0.102 "bash ~/ollama_pull.sh $MODEL_NAME"
echo -e "----\n"