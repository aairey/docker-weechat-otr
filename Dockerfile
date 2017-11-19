FROM docker.io/ubuntu:rolling
MAINTAINER aairey <airey.andy+docker@gmail.com>

ENV LAST_UPDATE=2017-11-19

RUN apt-get update && \
    apt-get upgrade -y

# Add locale and tzdata back, fix https://github.com/docker-library/official-images/issues/2863
RUN apt-get install --yes tzdata locales

# Set the timezone
RUN echo "Europe/Brussels" | tee /etc/timezone && \
    ln -fs /usr/share/zoneinfo/Europe/Brussels /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Set the locale for UTF-8 support
RUN echo en_US.UTF-8 UTF-8 >> /etc/locale.gen && \
    locale-gen && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN apt-get -y install \
    python-potr \
    python-requests \
    python-feedparser \
    python-websocket \
    python-yowsup \
    weechat \
    weechat-scripts

RUN adduser --disabled-login --gecos '' guest
USER guest
WORKDIR /home/guest

ADD config.txt config.txt

# Use config.txt only if no weechat configuration exists.
# If there is already a configuration in /home/guest/.weechat, ignore config.txt

ENTRYPOINT bash -c 'if [ -f "/home/guest/.weechat/irc.conf" ] ; then weechat ; else weechat -r "`cat config.txt | tr \"\\n\" \"\;\"`" ; fi'
