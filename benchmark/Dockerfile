# Use Ubuntu Noble as the base image
FROM ubuntu:noble

# Set environment variables
ENV JMETER_VERSION 5.6.3
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV PATH $JMETER_HOME/bin:$PATH

# Install dependencies
RUN apt-get update && apt-get install -y \
    openjdk-17-jre-headless \
    wget \
    unzip \
    && apt-get clean

# Download and install JMeter
RUN wget https://downloads.apache.org//jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz \
    && tar -xzf apache-jmeter-${JMETER_VERSION}.tgz -C /opt \
    && rm apache-jmeter-${JMETER_VERSION}.tgz

# Copy test plan into container
COPY newplan.jmx /newplan.jmx

# Run JMeter against localhost:8080 and save results to a CSV file
#CMD ["jmeter", "-n", "-t", "/testplan.jmx", "-l", "/results.csv", "-JserverHost=localhost", "-JserverPort=8080"]