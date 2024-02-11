FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
  apt-get install -y mysql-client git && \
  git clone https://github.com/herlesupreeth/kamailio

WORKDIR /init

COPY pyhss_init.sh /init/

RUN chmod +x /init/pyhss_init.sh

CMD /init/pyhss_init.sh