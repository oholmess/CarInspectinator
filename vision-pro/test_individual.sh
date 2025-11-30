#!/bin/bash

# Run each test class individually to find hanging tests
cd /Users/oliverholmes/Documents/Coding_Projects/CarInspectinator/vision-pro

echo "Testing MeasurementCodecTests..."
timeout 30 xcodebuild test \
  -project CarInspectinator.xcodeproj \
  -scheme CarInspectinator \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro,OS=26.1' \
  -only-testing:CarInspectinatorTests/MeasurementCodecTests 2>&1 | grep -E "TEST|PASSED|FAILED"

echo "Testing NetworkHandlerTests..."
timeout 30 xcodebuild test \
  -project CarInspectinator.xcodeproj \
  -scheme CarInspectinator \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro,OS=26.1' \
  -only-testing:CarInspectinatorTests/NetworkHandlerTests 2>&1 | grep -E "TEST|PASSED|FAILED"

echo "Testing CarServiceTests..."
timeout 30 xcodebuild test \
  -project CarInspectinator.xcodeproj \
  -scheme CarInspectinator \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro,OS=26.1' \
  -only-testing:CarInspectinatorTests/CarServiceTests 2>&1 | grep -E "TEST|PASSED|FAILED"

echo "Testing ModelDownloaderTests..."
timeout 30 xcodebuild test \
  -project CarInspectinator.xcodeproj \
  -scheme CarInspectinator \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro,OS=26.1' \
  -only-testing:CarInspectinatorTests/ModelDownloaderTests 2>&1 | grep -E "TEST|PASSED|FAILED"

echo "Testing HomePageViewModelTests..."
timeout 30 xcodebuild test \
  -project CarInspectinator.xcodeproj \
  -scheme CarInspectinator \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro,OS=26.1' \
  -only-testing:CarInspectinatorTests/HomePageViewModelTests 2>&1 | grep -E "TEST|PASSED|FAILED"

echo "Testing CarServiceIntegrationTests..."
timeout 30 xcodebuild test \
  -project CarInspectinator.xcodeproj \
  -scheme CarInspectinator \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro,OS=26.1' \
  -only-testing:CarInspectinatorTests/CarServiceIntegrationTests 2>&1 | grep -E "TEST|PASSED|FAILED"

