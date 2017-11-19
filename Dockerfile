# Dockerfile for aairey/weechat-otr

FROM docker.io/ubuntu:rolling
MAINTAINER aairey <airey.andy+docker@gmail.com>

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=latest
ARG DEBIAN_FRONTEND=noninteractive

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="weechat-otr" \
      org.label-schema.description="Run WeeChat with additional python libraries and OTR in Docker" \
      org.label-schema.url="https://www.weechat.org/" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/aairey/docker-weechat-otr" \
      org.label-schema.vendor="None" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

# Add locale and tzdata back, fix https://github.com/docker-library/official-images/issues/2863
RUN adduser --disabled-login --gecos '' guest && \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y \
        tzdata \
        locales \
        python-potr \
        python-requests \
        python-feedparser \
        python-websocket \
        python-yowsup \
        weechat \
        weechat-scripts

# Set the timezone
RUN echo "Europe/Brussels" | tee /etc/timezone && \
    ln -fs /usr/share/zoneinfo/Europe/Brussels /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    echo en_US.UTF-8 UTF-8 >> /etc/locale.gen && \
    locale-gen && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

USER guest
WORKDIR /home/guest
ADD config.txt config.txt

# Use config.txt only if no weechat configuration exists.
# If there is already a configuration in /home/guest/.weechat, ignore config.txt

ENTRYPOINT bash -c 'if [ -f "/home/guest/.weechat/irc.conf" ] ; then weechat ; else weechat -r "`cat config.txt | tr \"\\n\" \"\;\"`" ; fi'

