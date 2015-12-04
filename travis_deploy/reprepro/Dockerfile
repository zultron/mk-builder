FROM debian:jessie

MAINTAINER Ryan Smith-Roberts <rmsr@puri.sm>

ENV GOSU_VERSION 1.3

# grab gosu for easy step-down from root
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN apt-get -q update \
        && apt-get install -yq curl \
        && apt-get clean \
        && rm -r /var/lib/apt/lists/* \
        && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
        && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
        && gpg --verify /usr/local/bin/gosu.asc \
        && rm /usr/local/bin/gosu.asc \
        && chmod +x /usr/local/bin/gosu \
        && apt-get purge -y --auto-remove curl

RUN apt-get -q update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -yq \
            inoticoming \
            reprepro \
            python \
            python-irc \
        && apt-get clean \
        && rm -r /var/lib/apt/lists/*

RUN groupadd -r reprepro \
        && useradd -r -g reprepro -d /data reprepro

# override this to use a different rule for processincoming
ENV RULENAME incoming

ENV GNUPGHOME /data/.gnupg
ENV REPREPRO_PUBRING /conf/reprepro_pub.gpg
ENV REPREPRO_SECRING /conf/reprepro_sec.gpg
ENV REPREPRO_CONF_DIR /conf

VOLUME /conf /data

COPY ./reprepro-wrapper.sh /usr/local/bin/reprepro
COPY ./run.sh ./process-incoming.py /

CMD ["/run.sh"]
