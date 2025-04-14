SHELL=/bin/bash -o pipefail

release/md-babel_linux-amd64.tar.bz2 release/md-babel_linux-arm64.tar.bz2 &:
	docker buildx build --quiet --platform linux/amd64,linux/arm64 --tag md-babel/swift-markdown-babel --target export --output=./release/ .
	tar --create --bzip2 --file release/md-babel_linux-amd64.tar.bz2 --directory release/linux_amd64 md-babel
	tar --create --bzip2 --file release/md-babel_linux-arm64.tar.bz2 --directory release/linux_arm64 md-babel

.build/arm64-apple-macosx/release/md-babel:
	swift build --configuration release --triple arm64-apple-macosx

.build/x86_64-apple-macosx/release/md-babel:
	swift build --configuration release --triple x86_64-apple-macosx

release/md-babel_macos-universal.tar.bz2: .build/arm64-apple-macosx/release/md-babel .build/x86_64-apple-macosx/release/md-babel
	mkdir -p release/macos-universal
	lipo -create -output release/macos-universal/md-babel .build/{arm64,x86_64}-apple-macosx/release/md-babel
	tar --create --bzip2 --file release/md-babel_macos-universal.tar.bz2 --directory release/macos-universal md-babel

.PHONY: clean
clean:
	rm -rf release/*.tar.bz2 release/linux_*

.PHONY: release
release: release/md-babel_linux-arm64.tar.bz2 release/md-babel_linux-amd64.tar.bz2 release/md-babel_macos-universal.tar.bz2
