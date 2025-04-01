# Build image
FROM ubuntu:noble AS build

# Install OS updates
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install -y wget \
        xz-utils \
    && apt-get clean

# Copy entire repo into container
COPY ./javascript /app

# Install Node.js v22.14.0
RUN wget https://nodejs.org/dist/v22.14.0/node-v22.14.0-linux-x64.tar.xz -O node.tar.xz && \
    mkdir -p /usr/node && \
    tar -xf node.tar.xz --strip-components=1 --directory /usr/node && \
    rm node.tar.xz

# Add Node.js to PATH
ENV PATH="/usr/node/bin:${PATH}"

# Set working directory
WORKDIR /app

# Install Node.js dependencies
RUN npm install

# Run image
FROM ubuntu:noble

# Make sure all system packages are up to date
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && rm -r /var/lib/apt/lists/*

WORKDIR /app

# Copy node from the build stage
COPY --from=build /usr/node /usr/node

# Copy the application from the build stage
COPY --from=build /app /app

# Add Node.js to PATH
ENV PATH="/usr/node/bin:${PATH}"

# Let Docker bind to port 8080
EXPOSE 8080

# Set production environment
ENV NODE_ENV=production

# Start the server, binding to port 8080
CMD ["node", "index.js"]