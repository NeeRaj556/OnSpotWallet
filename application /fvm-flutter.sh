#!/bin/bash

# This script helps you run Flutter commands using FVM

# Check if FVM is installed
if ! command -v fvm &> /dev/null
then
    echo "FVM is not installed. Please install it first:"
    echo "dart pub global activate fvm"
    exit 1
fi

# Run Flutter command using FVM
.fvm/flutter_sdk/bin/flutter "$@"
