# Snapraid
FROM alpine:latest
ENV CRON_SCHEDULE=""

#install neded tools for compilation
RUN apk --update add python3 git smartmontools tzdata make g++ curl grep wget py3-pip 
# RUN apk add apprise --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/
RUN rm -rf /var/cache/apk/*

#download latest snapraid
RUN curl -s https://api.github.com/repos/amadvance/snapraid/releases/latest \
    | grep "browser.*snapraid.*tar.gz" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | wget -qi -
#extract    
RUN tar xzvf snapraid-*.tar.gz && \
    rm snapraid-*.tar.gz
#compile and check
RUN cd snapraid-* && \
    ./configure --prefix=/usr --sysconfdir=/etc --mandir=/usr/share/man --localstatedir=/var && \
    make && \
    make check  && \
    make install  && \
    cd .. && \
    rm -rf snapraid-*

RUN git clone https://github.com/D34DC3N73R/snapraid-btrfs.git /app/snapraid-btrfs && \
    chmod +x /app/snapraid-btrfs/snapraid-btrfs

#fetch and install latest snapraid-runner
RUN git clone https://github.com/fmoledina/snapraid-btrfs-runner.git /app/snapraid-btrfs-runner && \
    chmod +x /app/snapraid-btrfs-runner/snapraid-btrfs-runner.py

#mount config
VOLUME /mnt /config

COPY /docker-entry.sh  /
RUN chmod 755 /docker-entry.sh

CMD ["/docker-entry.sh"]
