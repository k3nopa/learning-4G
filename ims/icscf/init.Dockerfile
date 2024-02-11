FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
  apt-get install -y mysql-client git && \
  git clone https://github.com/herlesupreeth/kamailio

WORKDIR /init

COPY icscf_init.sh /init/
COPY icscf.sql /init/


RUN rm -rf /kamailio
RUN chmod +x /init/icscf_init.sh

CMD /init/icscf_init.sh