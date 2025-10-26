.PHONY: help build run clean screenshots dmg appstore install test

# Default target
help:
	@echo "🍩 TimeDonut - Make Commands"
	@echo "============================="
	@echo ""
	@echo "Development:"
	@echo "  make build       - アプリをビルド"
	@echo "  make run         - アプリをビルドして実行"
	@echo "  make clean       - ビルド成果物を削除"
	@echo "  make test        - テストを実行"
	@echo ""
	@echo "App Store Submission:"
	@echo "  make screenshots - スクリーンショットを撮影"
	@echo "  make appstore    - App Store用にビルド（署名付き）"
	@echo "  make dmg         - DMGファイルを作成"
	@echo ""
	@echo "Installation:"
	@echo "  make install     - /Applications にインストール"
	@echo ""

# Build the app
build:
	@echo "🔨 Building TimeDonut..."
	swift build
	./create-app-bundle.sh

# Build and run
run: build
	@echo "🚀 Running TimeDonut..."
	open TimeDonut.app

# Clean build artifacts
clean:
	@echo "🧹 Cleaning..."
	rm -rf .build/
	rm -rf build/
	rm -rf TimeDonut.app
	rm -f *.dmg
	@echo "✅ Clean complete"

# Take screenshots for App Store
screenshots:
	@echo "📸 Taking screenshots..."
	./take-screenshots.sh

# Build for App Store (signed)
appstore:
	@echo "🏪 Building for App Store..."
	./build-for-appstore.sh

# Create DMG
dmg: build
	@echo "💿 Creating DMG..."
	./create-dmg.sh

# Install to /Applications
install: build
	@echo "📦 Installing TimeDonut to /Applications..."
	cp -r TimeDonut.app /Applications/
	@echo "✅ Installed to /Applications/TimeDonut.app"

# Run tests
test:
	@echo "🧪 Running tests..."
	swift test
