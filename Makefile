release/md-babel_linux-amd64.tar.bz2 release/md-babel_linux-arm64.tar.bz2 &:
	docker buildx build --quiet --platform linux/amd64,linux/arm64 --tag md-babel/swift-markdown-babel --target export --output=./release/ .
	tar -cjf release/md-babel_linux-amd64.tar.bz2 -C release/linux_amd64 md-babel
	tar -cjf release/md-babel_linux-arm64.tar.bz2 -C release/linux_arm64 md-babel


.PHONY: release
release: release/md-babel_linux-arm64.tar.bz2 release/md-babel_linux-amd64.tar.bz2
