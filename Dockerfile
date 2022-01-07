# Snapraid 1.5
FROM alpine:latest
ARG SNAPRAID_VERSION=11.6 
# 12.0 has an error see issues

#install neded tools
RUN apk --update add python3 git smartmontools tzdata
#try installing snapraid from repo
RUN apk add snapraid=$SNAPRAID_VERSION --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing --allow-untrusted
#clear apk cache
RUN rm -rf /var/cache/apk/*

#fetch and install latest snapraid-runner
RUN git clone https://github.com/Chronial/snapraid-runner.git /app/snapraid-runner
RUN chmod +x /app/snapraid-runner/snapraid-runner.py

#install crontab
RUN echo '0 3 * * * /usr/bin/python3 /app/snapraid-runner/snapraid-runner.py -c /config/snapraid-runner.conf' > /etc/crontabs/root
#mount config
VOLUME /mnt /config

COPY /docker-entry.sh  /
RUN chmod 755 /docker-entry.sh

CMD ["/docker-entry.sh"]
