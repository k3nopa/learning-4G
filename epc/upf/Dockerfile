FROM ubuntu:focal as builder

ENV DEBIAN_FRONTEND=noninteractive

# Install updates and dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        ninja-build \
        build-essential \
        flex \
        bison \
        git \
        cmake \
        libsctp-dev \
        libgnutls28-dev \
        libgcrypt-dev \
        libssl-dev \
        libidn11-dev \
        libmongoc-dev \
        libbson-dev \
        libyaml-dev \
        meson \
        mongodb \
        curl \
        gnupg \
        ca-certificates \
        libmicrohttpd-dev \
        libcurl4-gnutls-dev \
        libnghttp2-dev \
        libtins-dev \
        libidn11-dev \
        libtalloc-dev

# Get open5gs code and install
RUN git clone --recursive https://github.com/open5gs/open5gs && cd open5gs && \
    git checkout 0abfb204ea2c1c5d677e7e99667f018599924f0e && \
    sed -i '/subdir/!b; /subdir('\'upf\'')/b; d' src/meson.build&& \
    sed -i '128,132d' meson.build && \
    meson build --prefix=`pwd`/install && \
    ninja -C build && cd build && ninja install && \
    mkdir -p /open5gs/install/include

# Build final image
FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        libssl-dev \
        libyaml-dev \
        libmicrohttpd-dev \
        libmongoc-dev \
        libsctp-dev \
        libcurl4-gnutls-dev \
        libtins-dev \
        libidn11-dev \
        libtalloc-dev \
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

RUN pip3 install click

RUN update-ca-certificates

COPY --from=builder /open5gs/install/bin /open5gs/install/bin
COPY --from=builder /open5gs/install/etc /open5gs/install/etc
COPY --from=builder /open5gs/install/include /open5gs/install/include
COPY --from=builder /open5gs/install/lib /open5gs/install/lib

# Set the working directory to open5gs
WORKDIR /open5gs

COPY ip_utils.py /open5gs/
COPY tun_if.py /open5gs/
COPY upf_init.sh /open5gs/init.sh
RUN chmod +x /open5gs/init.sh

ENV UE_IPV4_INTERNET 192.168.110.0/24
ENV UE_IPV4_IMS 192.168.120.0/24

CMD bash /open5gs/init.sh && \
    ./install/bin/open5gs-upfd