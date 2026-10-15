.PHONY: all build run install clean

all: build

build:
	@chmod +x build.sh
	@./build.sh

run: build
	@echo "🚀 Launching Caffeine..."
	@open Caffeine.app

install: build
	@echo "📦 Installing Caffeine to /Applications..."
	@rm -rf /Applications/Caffeine.app
	@cp -R Caffeine.app /Applications/
	@echo "✅ Caffeine installed to /Applications/Caffeine.app"

clean:
	@rm -rf Caffeine.app AppIcon.iconset .build
	@echo "🧹 Clean complete."
