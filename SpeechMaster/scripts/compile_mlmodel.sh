#!/bin/bash

# Script to compile Core ML model and copy it to the app resources

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ML_MODEL_DIR="$PROJECT_DIR/MLModel"
ML_PACKAGE_PATH="$ML_MODEL_DIR/fillerdetector.mlpackage"
OUTPUT_DIR="$PROJECT_DIR/SpeechMaster/Resources/MLModels"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Check if the ML package exists
if [ ! -d "$ML_PACKAGE_PATH" ]; then
    echo "Error: ML package not found at $ML_PACKAGE_PATH"
    exit 1
fi

# Compile the ML model
echo "Compiling ML model..."
xcrun coremlcompiler compile "$ML_PACKAGE_PATH" "$OUTPUT_DIR"

# Check if compilation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to compile ML model"
    exit 1
fi

echo "ML model compiled successfully and copied to $OUTPUT_DIR"
exit 0 