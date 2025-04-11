# syntax=docker/dockerfile:1

# Builds the CLI and moves it into:
#
#   /workspace/dist/

FROM --platform=$BUILDPLATFORM docker.io/swift:6.1.0 AS build
WORKDIR /workspace
RUN swift sdk install \
	https://download.swift.org/swift-6.1-release/static-sdk/swift-6.1-RELEASE/swift-6.1-RELEASE_static-linux-0.0.1.artifactbundle.tar.gz \
	--checksum 111c6f7d280a651208b8c74c0521dd99365d785c1976a6e23162f55f65379ac6

COPY ./Package.swift ./Package.resolved /workspace/
RUN --mount=type=cache,target=/workspace/.spm-cache,id=spm-cache \
	swift package \
	--cache-path /workspace/.spm-cache \
	--only-use-versions-from-resolved-file \
	resolve

COPY ./scripts /workspace/scripts
COPY ./Sources /workspace/Sources
COPY ./Tests /workspace/Tests
ARG TARGETPLATFORM
RUN --mount=type=cache,target=/workspace/.build,id=build-$TARGETPLATFORM \
	--mount=type=cache,target=/workspace/.spm-cache,id=spm-cache \
	scripts/build-release.sh && \
	mkdir -p dist && \
	cp .build/release/md-babel dist

# Export the build products to your host file system:
#
#   $ mkdir -p ./release
#   $ docker buildx build --platform linux/arm64,linux/amd64 --target export -o ./release .
#   $ ls ./release
#     linux_amd64
#     linux_arm64
FROM scratch AS export
COPY --from=build /workspace/dist/md-babel /
