# Use the latest Jenkins image as the base
FROM jenkins/jenkins:latest

# Switch to root user to install packages
USER root

# Update the package list and install lsb-release, a utility to get LSB (Linux Standard Base) version
RUN apt-get update && apt-get install -y lsb-release

# Download the Docker GPG key to ensure the software is authentic
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
    https://download.docker.com/linux/debian/gpg

# Add the Docker repository to the sources list of apt package manager.
# This uses the architecture of the machine and the version of the OS to fetch the appropriate version of Docker
RUN echo "deb [arch=$(dpkg --print-architecture) \
    signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
    https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# Update the package list again and install the Docker CLI. This does not install the Docker daemon
RUN apt-get update && apt-get install -y docker-ce-cli

# Switch back to the jenkins user before continuing with Jenkins setup
USER jenkins

# Install Jenkins plugins: Blue Ocean and Docker Workflow
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"
