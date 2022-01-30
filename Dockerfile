# Snapraid 1.5
FROM alpine:latest
ARG SNAPRAID_VERSION=12.1
ENV CRON_SCHEDULE=0 3 * * *
# 12.0 has an error see issues (segmentation fault)

#install neded tools for compilation
RUN apk --update add python3 git smartmontools tzdata make g++
#try installing snapraid from repo
#RUN apk add snapraid=$SNAPRAID_VERSION-r0 --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing --allow-untrusted
#clear apk cache
RUN rm -rf /var/cache/apk/*

#compile snapraid from source
RUN wget https://github.com/amadvance/snapraid/releases/download/v$SNAPRAID_VERSION/snapraid-$SNAPRAID_VERSION.tar.gz && \
    tar xzvf snapraid-$SNAPRAID_VERSION.tar.gz && \
    cd snapraid-$SNAPRAID_VERSION && \
    ./configure --prefix=/usr --sysconfdir=/etc --mandir=/usr/share/man --localstatedir=/var && \
    make && \
    make check  && \
    make install  && \
    cd .. && \
    rm -rf snapraid*

#fetch and install latest snapraid-runner
RUN git clone https://github.com/Chronial/snapraid-runner.git /app/snapraid-runner && \
    chmod +x /app/snapraid-runner/snapraid-runner.py

#install crontab
#RUN echo '0 3 * * * /usr/bin/python3 /app/snapraid-runner/snapraid-runner.py -c /config/snapraid-runner.conf' > /etc/crontabs/root
#mount config
VOLUME /mnt /config

COPY /docker-entry.sh  /
RUN chmod 755 /docker-entry.sh

CMD ["/docker-entry.sh"]
