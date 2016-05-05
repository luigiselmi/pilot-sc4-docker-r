Docker-R 
========
Builds a Docker image with R and Rserve. It contains also the R scripts with the definition of the functions for the map matching.
The map matching algorithm is used to map the position of a device given as a (longitude, latitude) pair to a street. The geographical
data, extracted from OpenStreetMap, is also added to the image. The area covered is the city of Thessaloniki, Greece. 

## Description
This component executes remotely R commands from a Java application. It is used in the BDE - SC4 Pilot to execute a map matching algorithm 
written in R from a java application.
##Documentation 
This component is based on Rserve (https://rforge.net/Rserve/doc.html)
##Requirements 
This component requires a Docker engine installed in the host where it is run.
##Build 
A docker image can be built with the command

    $ docker build -t bde2020/pilot-sc4-rserve:latest .

##Install and Run
Start the docker container with the command

    $ docker run -d -p 6311:6311 bde2020/pilot-sc4-rserve:latest 

This starts a container with R and Rserve installed. In order to start Rserve run the command

    $ docker exec -d <container> ./start_rserve.sh

where <container> is a place holder for the container name or id. The Rserve will listen to the default port (6311).
The port can be changed in the Rserve.conf file. The same port number must be used in the Docker file (EXPOSE) and when 
the container is started.
##Usage 
This component provides a map matching service based on R, Rserve and some R functions. It can be used by an Rserve client embedded in a java application.


##License 
TBD
