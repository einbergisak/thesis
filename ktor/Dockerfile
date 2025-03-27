# Build image
FROM ubuntu:noble AS build

# Install OS updates
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install -y openjdk-21-jdk-headless \
    && apt-get clean

# Copy entire repo into container
COPY ./kotlin /app

# Install JDK 21
# RUN wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz -O java.tar.gz && \
#     mkdir -p /usr/jdk21 && \
#     tar -xzf java.tar.gz --strip-components=1 --directory /usr/jdk-21 && \
#     rm java.tar.gz

# Set working directory
WORKDIR /app

# Build Kotlin project
RUN ./gradlew build

# Run image
FROM ubuntu:noble

# Make sure all system packages are up to date
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install -y openjdk-21-jdk-headless \
    && rm -r /var/lib/apt/lists/*

WORKDIR /app

# Copy the application from the build stage
COPY --from=build /app/build/libs/*.jar /app/ktor-app.jar

# Let Docker bind to port 8080
EXPOSE 8080

# Start the server, binding to port 8080
# Container flag ensures that JVM is aware of the container limits, instead of using the host limits
CMD ["java", \
 "-XX:+UseContainerSupport", \
 "-jar", "/app/ktor-app.jar"]
# CMD ["java", "-jar", "/app/app.jar"]