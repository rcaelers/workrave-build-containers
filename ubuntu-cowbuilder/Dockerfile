FROM ubuntu:jammy

LABEL maintainer "Rob Caelers <rob.caelers@gmail.com>"

ARG GIT_COMMIT_HASH
ENV WORKRAVE_CONTAINER_COMMIT=${GIT_COMMIT_HASH}
RUN mkdir /workrave && \
    echo ${GIT_COMMIT_HASH} > /workrave/container-commit

RUN \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get update -y && \
  apt-get install -y debian-archive-keyring cowbuilder pbuilder && \
  apt-get clean

COPY pbuilderrc /root/.pbuilderrc

RUN for dist in kinetic jammy impish focal bionic unstable testing stable; do \
       DIST=$dist cowbuilder --create --distribution $dist --basepath /var/cache/pbuilder/base-$dist.cow; \
    done

CMD ["/bin/bash"]
