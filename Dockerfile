# Docker file for the First SC4 Pilot of the Big Data Europe project
# It provides R with a proxy (Rserve) to which a client can connect
# via a Java application. This image include the official base R image
# Rserve, some R scripts and shape files.

FROM r-base:latest
MAINTAINER Luigi Selmi <luigiselmi@gmail.com>
WORKDIR /home/sc4pilot
RUN wget https://github.com/luigiselmi/pilot-sc4-docker-r/raw/master/rserve/Rserve_1.8-5.tar.gz && \
    tar xvf Rserve_1.8-5.tar.gz
