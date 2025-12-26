# Use the latest Debian image as base
FROM debian:latest

# Set the environment to non-interactive (to prevent prompts)
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    lsb-release \
    build-essential \
    git \
    bash-completion \
    octave \
    octave-dev \
    octave-doc \
    octave-control \
    octave-signal \
    octave-image \
    octave-io \
    octave-optim \
    octave-statistics \
    octave-communications \
    && rm -rf /var/lib/apt/lists/*

# Set the default command to run octave when the container starts
CMD ["octave"]