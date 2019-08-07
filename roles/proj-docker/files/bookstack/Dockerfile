FROM linuxserver/bookstack

COPY ./varb-ca.crt /usr/local/share/ca-certificates/varb-ca.crt

RUN apk update \
 && apk --no-cache add ca-certificates \
 && update-ca-certificates
