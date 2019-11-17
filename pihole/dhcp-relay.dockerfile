FROM debian
RUN apt-get update -y && apt-get upgrade -y && \
apt install isc-dhcp-relay && \
apt-get clean && rm -rf /var/lib/apt/lists/*

ARG INTERFACE_UPSTREAM
ARG INTERFACE_DOWNSTREAM
ARG SERVER

RUN export INTERFACE_UPSTREAM=${INTERFACE_UPSTREAM} &&  \
export INTERFACE_DOWNSTREAM=${INTERFACE_DOWNSTREAM} && \
export SERVER=${SERVER}

EXPOSE 67/udp

CMD dhcrelay -4 -d -id $INTERFACE_DOWNSTREAM -iu $INTERFACE_UPSTREAM $SERVER
