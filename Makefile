.PHONY: help build run clean screenshots dmg appstore install test setup-certs configure submit

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
	@echo "App Store Setup:"
	@echo "  make setup-certs - 証明書のセットアップ（ガイド付き）"
	@echo "  make configure   - Xcodeプロジェクト設定（ガイド付き）"
	@echo "  make submit      - 🚀 完全自動セットアップ（全ステップ実行）"
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

# Setup certificates (guided)
setup-certs:
	@echo "🔐 Setting up certificates..."
	./setup-certificates.sh

# Configure Xcode project (guided)
configure:
	@echo "⚙️  Configuring Xcode..."
	./configure-xcode.sh

# Complete App Store submission setup (all steps)
submit:
	@echo "🚀 Starting complete App Store submission setup..."
	./complete-appstore-setup.sh
