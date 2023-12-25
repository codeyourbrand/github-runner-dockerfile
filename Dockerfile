FROM ubuntu:20.04

ARG RUNNER_VERSION="2.311.0"
ARG PLATFORM="arm64"
ARG DOCKER_GROUP_ID="994"

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

### Install docker client
# Install dependencies for Docker installation
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Add Docker’s official GPG key
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# Set up the Docker repository
RUN add-apt-repository \
   "deb [arch=arm64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Install Docker CLI
RUN apt-get update -y && apt upgrade && apt-get install -y docker-ce-cli

# Add your user to the host docker group
RUN groupadd -g ${DOCKER_GROUP_ID} docker

# Create the docker user and add it to the docker group
RUN useradd -m -d /home/docker -s /bin/bash -g docker docker

## Install github runner
# Install github runner dependencies    
RUN apt install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

# Install github runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${PLATFORM}-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-${PLATFORM}-${RUNNER_VERSION}.tar.gz

RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

COPY start.sh start.sh
RUN chmod +x start.sh

# Install AWS CLI using pip
RUN pip3 install awscli

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

ENTRYPOINT ["./start.sh"]
