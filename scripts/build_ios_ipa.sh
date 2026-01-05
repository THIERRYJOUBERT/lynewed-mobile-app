#!/bin/bash

# Build iOS .ipa for App Store submission
# This script creates a production-ready .ipa file

echo "🚀 Starting iOS .ipa build process..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
rm -rf build/
cd ios
rm -rf build/
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*

# Install dependencies
echo "📦 Installing dependencies..."
pod install

# Build archive for App Store
echo "📱 Building archive for App Store..."
xcodebuild -workspace Runner.xcworkspace \
           -scheme Runner \
           -configuration Release \
           -destination generic/platform=iOS \
           -archivePath build/Runner.xcarchive \
           archive \
           CODE_SIGN_STYLE=Automatic \
           CODE_SIGN_IDENTITY="iPhone Distribution" \
           PROVISIONING_PROFILE_SPECIFIER=""

# Export .ipa from archive
echo "📦 Exporting .ipa from archive..."
xcodebuild -exportArchive \
           -archivePath build/Runner.xcarchive \
           -exportOptionsPlist ExportOptions.plist \
           -exportPath build/output

echo "✅ Build complete! .ipa file located at: ios/build/output/Runner.ipa"
