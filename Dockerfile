# Ubuntu Noble 24.04 for amd64 specifically
FROM --platform=linux/amd64 ubuntu:24.04

# Install without user interaction
ENV DEBIAN_FRONTEND=noninteractive

# Update and install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    xz-utils \
    # <-- Swift dependencies https://www.swift.org/install/linux/tarball/-->
    binutils \
    git \
    gnupg2 \
    libc6-dev \
    libcurl4-openssl-dev \
    libedit2 \
    libgcc-13-dev \
    libncurses-dev \
    libpython3-dev \
    libsqlite3-0 \
    libstdc++-13-dev \
    libxml2-dev \
    libz3-dev \
    pkg-config \
    tzdata \
    unzip \
    zlib1g-dev \
    # <-- -->
    #libjemalloc2 \
    && apt-get clean

# Install perf from kernel website for Ubuntu 20.04

# Install Swift 6.0.3
RUN wget https://download.swift.org/swift-6.0.3-release/ubuntu2404/swift-6.0.3-RELEASE/swift-6.0.3-RELEASE-ubuntu24.04.tar.gz -O swift.tar.gz && \
    mkdir -p /usr/swift && \
    tar -xzf swift.tar.gz --strip-components=1 --directory /usr/swift && \
    rm swift.tar.gz

# Install JDK 21
RUN wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz -O java.tar.gz && \
    mkdir -p /usr/jdk21 && \
    tar -xzf java.tar.gz --strip-components=1 --directory /usr/jdk-21 && \
    rm java.tar.gz

# Install Node.js v22.14.0
RUN wget https://nodejs.org/dist/v22.14.0/node-v22.14.0-linux-x64.tar.xz -O node.tar.xz && \
    mkdir -p /usr/node && \
    tar -xf node.tar.xz --strip-components=1 --directory /usr/node && \
    rm node.tar.xz

# Add Swift, Java, and Node.js to PATH
ENV PATH="/usr/swift/usr/bin:/usr/jdk-21/bin:/usr/node/bin:${PATH}"

# Set working directory
WORKDIR /app

# Copy and compile Swift files
COPY ./swift /app/vapor
#RUN cd /app/swift && swift build

# Copy and compile JavaScript files
COPY ./javascript /app/express
# RUN cd /app/express && npm install

# Copy and compile Kotlin files
COPY ./kotlin /app/ktor
# RUN cd /app/ktor && ./gradlew build

# Expose ports for the applications
EXPOSE 8081 8082 8083

CMD ["bash"]