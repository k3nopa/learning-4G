FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
  apt-get install -y mysql-client git && \
  git clone https://github.com/herlesupreeth/kamailio

WORKDIR /init

COPY scscf_init.sh /init/

RUN cp /kamailio/utils/kamctl/mysql/standard-create.sql \ 
  /kamailio/utils/kamctl/mysql/presence-create.sql \
  /kamailio/utils/kamctl/mysql/ims_usrloc_scscf-create.sql \
  /kamailio/utils/kamctl/mysql/ims_dialog-create.sql \
  /kamailio/utils/kamctl/mysql/ims_charging-create.sql \
  /init/

RUN rm -rf /kamailio
RUN chmod +x /init/scscf_init.sh

CMD /init/scscf_init.sh