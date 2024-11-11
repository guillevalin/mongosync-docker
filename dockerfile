FROM ubuntu:latest
WORKDIR /tmp

ARG VERSION=1.6.1
ARG SRC_URI
ARG DST_URI
EXPOSE 27182

RUN apt-get update && apt-get install -y curl
RUN curl https://fastdl.mongodb.org/tools/mongosync/mongosync-ubuntu2004-x86_64-${VERSION}.tgz -o mongosync-ubuntu2004-x86_64-${VERSION}.tgz
RUN tar -xvzf mongosync-ubuntu2004-x86_64-${VERSION}.tgz
RUN cp mongosync-ubuntu2004-x86_64-${VERSION}/bin/mongosync /usr/local/bin/
RUN mongosync -v

CMD mongosync --cluster0 ${SRC_URI} --cluster1 ${DST_URI}