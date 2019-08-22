FROM node:10-slim

LABEL maintainer="Jake Jarvis <jake@jarv.is>"

# Install and upgrade utilities
RUN apt-get update --fix-missing && apt-get -y upgrade

# Install latest Chrome stable.
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /src/*.deb

# Download latest Lighthouse from npm.
# Cache bust to ensure latest version when building the image.
ARG CACHEBUST=1
RUN npm install -g lighthouse

# Add a chrome user and setup home dir for reports.
RUN groupadd --system chrome && \
    useradd --system --create-home --gid chrome --groups audio,video chrome && \
    mkdir --parents /home/chrome/reports && \
    chown --recursive chrome:chrome /home/chrome

USER chrome

VOLUME /home/chrome/reports
WORKDIR /home/chrome/reports

# Disable Lighthouse error reporting to prevent prompt.
ENV CI=true

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]