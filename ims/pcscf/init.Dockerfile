FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
  apt-get install -y mysql-client git && \
  git clone https://github.com/herlesupreeth/kamailio

WORKDIR /init

COPY pcscf_init.sh /init/

RUN cp /kamailio/utils/kamctl/mysql/standard-create.sql \ 
  /kamailio/utils/kamctl/mysql/dialplan-create.sql \
  /kamailio/utils/kamctl/mysql/presence-create.sql \
  /init/

RUN rm -rf /kamailio
RUN chmod +x /init/pcscf_init.sh

CMD /init/pcscf_init.sh