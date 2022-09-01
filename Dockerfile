# Snapraid
FROM alpine:latest
ENV CRON_SCHEDULE=""

#install neded tools for compilation
RUN apk --update add python3 git smartmontools tzdata make g++
RUN rm -rf /var/cache/apk/*

#download latest snapraid
RUN curl -s https://api.github.com/repos/amadvance/snapraid/releases/latest \
    | grep "browser.*snapraid.*tar.gz" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | wget -qi -
#extract    
RUN tar xzvf snapraid-*.tar.gz && \
    rm snapraid-*.tar.gz && \
    cd snapraid-*
#compile and check
RUN ./configure --prefix=/usr --sysconfdir=/etc --mandir=/usr/share/man --localstatedir=/var && \
    make && \
    make check  && \
    make install  && \
    cd .. && \
    rm -rf snapraid-*

#fetch and install latest snapraid-runner
RUN git clone https://github.com/fightforlife/snapraid-runner.git /app/snapraid-runner && \
    chmod +x /app/snapraid-runner/snapraid-runner.py

#install apprise
RUN python3 -m ensurepip --upgrade
RUN pip3 install apprise

#mount config
VOLUME /mnt /config

COPY /docker-entry.sh  /
RUN chmod 755 /docker-entry.sh

CMD ["/docker-entry.sh"]
