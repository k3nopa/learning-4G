FROM ubuntu:focal as builder

ENV DEBIAN_FRONTEND=noninteractive

# Install updates and dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        build-essential \
        flex \
        bison \
        git \
        libmongoc-dev \
        mongodb \
        curl \
        gnupg \
        ca-certificates 

RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    NODE_MAJOR=20 && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && apt install nodejs -y

# Get open5gs code
RUN git clone --recursive https://github.com/open5gs/open5gs && cd open5gs && \
    git checkout 0abfb204ea2c1c5d677e7e99667f018599924f0e

# Building WebUI of open5gs
RUN cd open5gs/webui && npm ci

# Build final image
FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        libmongoc-dev \
        netbase \
        ifupdown \
        net-tools \
        iputils-ping \
        python3-setuptools \
        python3-wheel \
        python3-pip \
        iptables \
        iperf \
        tcpdump \
        gnupg && \
    apt-get autoremove -y && apt-get autoclean

RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    NODE_MAJOR=20 && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && apt install nodejs -y

RUN update-ca-certificates

COPY --from=builder /open5gs/webui /open5gs/webui

# Set the working directory to open5gs
WORKDIR /open5gs

CMD cd webui && npm run dev
