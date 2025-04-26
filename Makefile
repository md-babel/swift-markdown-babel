SHELL=/bin/bash -o pipefail

prefix ?= /usr/local
bindir = $(prefix)/bin

version := $(shell git describe --tags)

# NB: '$$' in Makefile essentially escapes the '$'; on the command line, the perl parameter would only use a single '$'.
#     The 'FRM' is enough of a hint to find my team ID locally, but this won't work when building via GitHub actions.
codesign_id ?= $(shell security find-identity -p basic -v | perl -lnE 'if(/("Developer ID Application: [^"]+")/){say "$$1"}' | grep FRM)

linux_files = release/md-babel_linux-amd64-$(version).tar.bz2 release/md-babel_linux-arm64-$(version).tar.bz2

$(linux_files) &:
	docker buildx build --quiet --platform linux/amd64,linux/arm64 --tag md-babel/swift-markdown-babel --target export --output=./release/ .
	tar --create --bzip2 --file release/md-babel_linux-amd64-$(version).tar.bz2 --directory release/linux_amd64 md-babel
	tar --create --bzip2 --file release/md-babel_linux-arm64-$(version).tar.bz2 --directory release/linux_arm64 md-babel

.build/$(version)/arm64-apple-macosx/release/md-babel:
	swift build --quiet --scratch-path .build/$(version) --configuration release --triple arm64-apple-macosx

.build/$(version)/x86_64-apple-macosx/release/md-babel:
	swift build --quiet --scratch-path .build/$(version) --configuration release --triple x86_64-apple-macosx

release/macos-universal-$(version)/md-babel: .build/$(version)/arm64-apple-macosx/release/md-babel .build/$(version)/x86_64-apple-macosx/release/md-babel
	mkdir -p release/macos-universal-$(version)
	lipo -create -output release/macos-universal-$(version)/md-babel .build/$(version)/{arm64,x86_64}-apple-macosx/release/md-babel
	codesign --sign $(codesign_id) --options runtime --timestamp release/macos-universal-$(version)/md-babel

release/md-babel_macos-universal-$(version).tar.bz2: release/macos-universal-$(version)/md-babel
	tar --create --bzip2 --file release/md-babel_macos-universal-$(version).tar.bz2 --directory release/macos-universal-$(version) md-babel

.PHONY: clean
clean:
	rm -rf release/*.tar.bz2 release/linux_* release/macos* release/md-babel*

.PHONY: release
release: $(linux_files) release/md-babel_macos-universal-$(version).tar.bz2


.PHONY: build
build:
	swift build --configuration release

.PHONY: install
install: build
	install -d "$(bindir)"
	install ".build/release/md-babel" "$(bindir)"
