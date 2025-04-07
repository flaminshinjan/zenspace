#!/bin/bash

# Remove existing schemes
xcodebuild -workspace Runner.xcworkspace -scheme Runner-Dev clean
xcodebuild -workspace Runner.xcworkspace -scheme Runner-Prod clean
xcodebuild -workspace Runner.xcworkspace -scheme Runner-Testing clean

# Create Dev scheme
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16' build
xcrun xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16' -showBuildSettings | grep "PRODUCT_BUNDLE_IDENTIFIER" | sed 's/.*= //' > /tmp/bundle_id
xcrun xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16' -showBuildSettings | grep "PRODUCT_NAME" | sed 's/.*= //' > /tmp/product_name

# Create Prod scheme
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -destination 'platform=iOS Simulator,name=iPhone 16' build
xcrun xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -destination 'platform=iOS Simulator,name=iPhone 16' -showBuildSettings | grep "PRODUCT_BUNDLE_IDENTIFIER" | sed 's/.*= //' > /tmp/bundle_id
xcrun xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -destination 'platform=iOS Simulator,name=iPhone 16' -showBuildSettings | grep "PRODUCT_NAME" | sed 's/.*= //' > /tmp/product_name

# Create Testing scheme
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16' build
xcrun xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16' -showBuildSettings | grep "PRODUCT_BUNDLE_IDENTIFIER" | sed 's/.*= //' > /tmp/bundle_id
xcrun xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16' -showBuildSettings | grep "PRODUCT_NAME" | sed 's/.*= //' > /tmp/product_name

echo "iOS schemes have been set up successfully!" 