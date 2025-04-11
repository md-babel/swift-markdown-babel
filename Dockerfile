# ================================
# Build image
# ================================
FROM swift:6.1.0-noble AS build

# Install OS updates
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install -y libjemalloc-dev

# Set up a build area
WORKDIR /build

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
RUN swift package resolve \
    $([ -f ./Package.resolved ] && echo "--force-resolved-versions" || true)

# Copy entire repo into container
COPY . .

# Build the application
RUN swift build -c release \
    --product md-babel \
    --static-swift-stdlib

WORKDIR /staging

# Copy main executable to staging area
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/md-babel" ./

# ================================
# Export build product
# ================================
# Usage:
#  $ docker build --target export -o . .
FROM scratch AS export
COPY --from=build /staging/md-babel /
