# Dockerfile for aairey/weechat-otr

FROM docker.io/ubuntu:18.04
MAINTAINER aairey <airey.andy+docker@gmail.com>

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=2.4
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
    apt-get update && apt-get -y upgrade && \
    apt-get install -y gnupg2 ca-certificates apt-transport-https && \
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 11E9DE8848F2B65222AA75B8D1820DB22A11534E && \
    echo "deb https://weechat.org/ubuntu bionic main" | tee /etc/apt/sources.list.d/weechat.list && \
    echo "deb-src https://weechat.org/ubuntu bionic main" | tee -a /etc/apt/sources.list.d/weechat.list && \
    apt-get update && \
    apt-get install -y \
        tzdata \
        locales \
        aspell-en aspell-fr aspell-de aspell-nl \
        wget \
        lua-cjson \
        python-potr \
        python-requests \
        python-feedparser \
        python-websocket \
        python-yowsup \
        python-pip \
        weechat-curses weechat-headless weechat-plugins weechat-python weechat-perl weechat-lua && \
    pip install yowsup2 websocket-client && \
    mkdir -p /home/guest/.weechat/python/autoload /home/guest/.weechat/lua/autoload && \
    wget "https://raw.githubusercontent.com/mmb/weechat-otr/master/weechat_otr.py" -O /home/guest/.weechat/python/otr.py && \
    wget "https://raw.githubusercontent.com/wee-slack/wee-slack/master/wee_slack.py" -O /home/guest/.weechat/python/wee_slack.py && \
    wget "https://raw.githubusercontent.com/torhve/weechat-matrix-protocol-script/master/matrix.lua" -O /home/guest/.weechat/lua/matrix.lua && \
    wget "https://raw.githubusercontent.com/torhve/weechat-matrix-protocol-script/master/olm.lua" -O /home/guest/.weechat/lua/olm.lua && \
    ln -s /home/guest/.weechat/python/otr.py /home/guest/.weechat/python/autoload && \
    ln -s /home/guest/.weechat/python/wee_slack.py /home/guest/.weechat/python/autoload && \
    ln -s /home/guest/.weechat/lua/matrix.lua /home/guest/.weechat/lua/autoload && \
    chown -R guest:guest /home/guest/.weechat

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

CMD bash -c 'if [ -f "/home/guest/.weechat/irc.conf" ] ; then weechat ; else weechat -r "`cat config.txt | tr \"\\n\" \"\;\"`" ; fi'

