#!/bin/bash

echo -e "WARMUP OLLAMA\n"
echo -e "---------------\n"
echo -e "\n"
echo -e "\n"

curl http://10.0.0.100:11434/api/generate -d '{
  "model": "model1",
  "prompt": "Tell me a joke", "keep_alive": -1
}'

curl http://10.0.0.101:11434/api/generate -d '{
  "model": "model2",
  "prompt": "Tell me a joke", "keep_alive": -1
}'

curl http://10.0.0.102:11434/api/generate -d '{
  "model": "model3",
  "prompt": "Tell me a joke", "keep_alive": -1
}'