release/md-babel_linux-amd64.tar.bz2:
	docker buildx build --quiet --platform linux/amd64 --tag md-babel/swift-markdown-babel --target export --output=./release/ .
	cd release && tar -cjf md-babel_linux-amd64.tar.bz2 -C linux_amd64 md-babel

release/md-babel_linux-arm64.tar.bz2:
	docker buildx build --quiet --platform linux/arm64 --tag md-babel/swift-markdown-babel --target export --output=./release/ .
	cd release && tar -cjf md-babel_linux-arm64.tar.bz2 -C linux_arm64 md-babel

.PHONY: build
build:
	docker buildx build --quiet --platform linux/amd64,linux/arm64 --tag md-babel/swift-markdown-babel --target export --output=./release/ .

.PHONY: release
release: release/md-babel_linux-arm64.tar.bz2 release/md-babel_linux-amd64.tar.bz2
