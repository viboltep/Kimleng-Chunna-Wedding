#!/bin/bash

# Kimleng & Chunna Wedding Invitation - Deployment Script

echo "🎉 Building Kimleng & Chunna Wedding Invitation..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for web
echo "🏗️ Building for web..."
flutter build web --release

echo "✅ Build completed successfully!"
echo "📁 Built files are in: build/web/"

# Optional: Deploy to Firebase (uncomment if using Firebase)
# echo "🚀 Deploying to Firebase..."
# firebase deploy

echo "🎊 Ready for deployment!"
echo ""
echo "Next steps:"
echo "1. Upload build/web/ contents to your hosting service"
echo "2. Or use Firebase: firebase deploy"
echo "3. Or use GitHub Pages: copy to docs/ folder and push"
