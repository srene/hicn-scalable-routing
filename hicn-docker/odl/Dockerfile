FROM ubuntu:18.04
MAINTAINER s.rene@ucl.ac.uk

RUN apt-get update
RUN apt-get install -y curl wget openjdk-11-jdk \
   && rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove -y \
    && apt-get clean

RUN mkdir /opt/opendaylight && \
    wget https://nexus.opendaylight.org/content/repositories/opendaylight.release/org/opendaylight/integration/opendaylight/0.13.1/opendaylight-0.13.1.tar.gz && \
    tar -zxvf opendaylight-0.13.1.tar.gz -C /opt/opendaylight --strip-components 1

#WORKDIR /opt/opendaylight

EXPOSE 8181 8101

COPY start.sh /

COPY start.xml /

ENTRYPOINT ["bash","/start.sh"]
