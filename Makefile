SHELL=/bin/bash -o pipefail

version := $(shell git describe --tags)

linux_files = release/md-babel_linux-amd64-$(version).tar.bz2 release/md-babel_linux-arm64-$(version).tar.bz2

$(linux_files) &:
	docker buildx build --quiet --platform linux/amd64,linux/arm64 --tag md-babel/swift-markdown-babel --target export --output=./release/ .
	tar --create --bzip2 --file release/md-babel_linux-amd64-$(version).tar.bz2 --directory release/linux_amd64 md-babel
	tar --create --bzip2 --file release/md-babel_linux-arm64-$(version).tar.bz2 --directory release/linux_arm64 md-babel

.build/$(version)/arm64-apple-macosx/release/md-babel:
	swift build --quiet --scratch-path .build/$(version) --configuration release --triple arm64-apple-macosx

.build/$(version)/x86_64-apple-macosx/release/md-babel:
	swift build --quiet --scratch-path .build/$(version) --configuration release --triple x86_64-apple-macosx

release/md-babel_macos-universal-$(version).tar.bz2: .build/$(version)/arm64-apple-macosx/release/md-babel .build/$(version)/x86_64-apple-macosx/release/md-babel
	mkdir -p release/macos-universal-$(version)
	lipo -create -output release/macos-universal-$(version)/md-babel .build/$(version)/{arm64,x86_64}-apple-macosx/release/md-babel
	tar --create --bzip2 --file release/md-babel_macos-universal-$(version).tar.bz2 --directory release/macos-universal-$(version) md-babel

.PHONY: clean
clean:
	rm -rf release/*.tar.bz2 release/linux_* release/macos* release/md-babel*

.PHONY: release
release: $(linux_files) release/md-babel_macos-universal-$(version).tar.bz2
