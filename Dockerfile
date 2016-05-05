# Docker file for the First SC4 Pilot of the Big Data Europe project
# It provides R with a proxy (Rserve) to which a client can connect
# via a Java application. This image include the official base R image
# Rserve, some R scripts and shape files.
# 1) Build an image using this docker file. Run the following docker command
# docker build -t bde2020/pilot-sc4-rserve:latest .
# 2) Run a container with Rserve. Run the following docker command
# docker run -p 6311:6311 bde2020/pilot-sc4-rserve:latest
# Use -d to start the service as a daemon (docker run -d -p 6311:6311 bde202/pilot-sc4-rserve )
 
# Pull base image
FROM rocker/ropensci
MAINTAINER Luigi Selmi <luigiselmi@gmail.com>
ADD rserve/ /home/sc4pilot/rserve/
ADD geodata/ /home/sc4pilot/geodata/
ADD test/ /home/sc4pilot/test/
ADD match.R start_rserve.sh Rserve.conf mapmatchfunctions.R /home/sc4pilot/rserve/
WORKDIR /home/sc4pilot/rserve
EXPOSE 6311
RUN ["R", "CMD", "INSTALL", "Rserve_1.8-5.tar.gz"]
#CMD ["sh", "start_rserve.sh"]


