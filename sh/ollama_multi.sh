#!/bin/bash

# Number of GPUs
GPUS=5

# Ollama default port
OLLAMA_DEFAULT_PORT=11500

# Additional Ollama options
export OLLAMA_NUM_PARALLEL=5
export OLLAMA_KEEP_ALIVE=-1
export OLLAMA_MODELS=/usr/share/ollama/.ollama/models

# Define the model to run on each instance
MODEL="mistral"

# Loop through each GPU and start an Ollama instance and run the model
for ((i=0; i<GPUS; i++)); do
    export ROCR_VISIBLE_DEVICES=$i
    export OLLAMA_HOST=0.0.0.0:$((OLLAMA_DEFAULT_PORT + i))

    echo "Starting Ollama on GPU $i at port $((OLLAMA_DEFAULT_PORT + i))"
    ollama serve &

    # Give a delay to allow the server to initialize
    sleep 5

    echo "Running model ${MODEL} on GPU $i at port $((OLLAMA_DEFAULT_PORT + i))"
    OLLAMA_HOST=0.0.0.0:$((OLLAMA_DEFAULT_PORT + i)) ollama run ${MODEL} &

    sleep 2
done

# Wait for all background processes to finish
wait