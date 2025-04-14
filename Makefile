release/md-babel_linux-amd64.tar.bz2 release/md-babel_linux-arm64.tar.bz2 &:
	docker buildx build --quiet --platform linux/amd64,linux/arm64 --tag md-babel/swift-markdown-babel --target export --output=./release/ .
	tar --create --bzip2 --file release/md-babel_linux-amd64.tar.bz2 --directory release/linux_amd64 md-babel
	tar --create --bzip2 --file release/md-babel_linux-arm64.tar.bz2 --directory release/linux_arm64 md-babel


.PHONY: release
release: release/md-babel_linux-arm64.tar.bz2 release/md-babel_linux-amd64.tar.bz2
