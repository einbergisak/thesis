# Use Ubuntu Noble as the base image
FROM ubuntu:noble

# Install dependencies
RUN apt-get update && apt-get install -y \
    openjdk-17-jre-headless \
    wget \
    unzip \
    && apt-get clean

# Download and install JMeter
RUN wget https://downloads.apache.org//jmeter/binaries/apache-jmeter-5.6.3.tgz \
    && tar -xzf apache-jmeter-5.6.3.tgz -C /opt \
    && rm apache-jmeter-5.6.3.tgz

# Add to PATH
ENV PATH="/opt/apache-jmeter-5.6.3/bin:${PATH}"

#CMD ["jmeter", "-n", "-t", "/testplan.jmx", "-l", "/results.csv", "-JserverHost=localhost", "-JserverPort=8080"]