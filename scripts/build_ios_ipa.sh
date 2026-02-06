#!/bin/bash

# Build iOS .xcarchive for App Store submission
# After archive, open in Xcode Organizer to distribute via App Store Connect / Transporter

set -e

echo "🚀 Starting iOS archive build process..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
rm -rf ios/build/
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*

# Restore dependencies (required after flutter clean)
echo "📦 Restoring Flutter dependencies..."
flutter pub get

# Install CocoaPods
echo "📦 Installing CocoaPods..."
cd ios
pod install
cd ..

# Build archive for App Store
echo "📱 Building archive for App Store..."
cd ios
xcodebuild -workspace Runner.xcworkspace \
           -scheme Runner \
           -configuration Release \
           -destination generic/platform=iOS \
           -archivePath build/Runner.xcarchive \
           archive \
           CODE_SIGN_STYLE=Automatic

# Check archive success
if [ ! -d "build/Runner.xcarchive" ]; then
    echo "❌ Archive failed!"
    exit 1
fi

# Open in Xcode Organizer for distribution
echo "📦 Opening archive in Xcode Organizer..."
open build/Runner.xcarchive

echo "✅ Archive complete! Xcode Organizer opened."
echo "→ Select the archive → Distribute App → App Store Connect"
echo "→ Or export .ipa and upload via Transporter"
