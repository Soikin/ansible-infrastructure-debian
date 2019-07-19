FROM python:3.7.4-alpine

EXPOSE 8080

ENV USER=lpw \
    UID=472 \
    GID=472

COPY ./varb-ca.crt /usr/local/share/ca-certificates/varb-ca.crt
COPY ./source /srv/ldap-passwd-webui
COPY ./settings.ini /srv/ldap-passwd-webui/settings.ini

RUN apk update \
 && apk --no-cache add ca-certificates \
 && update-ca-certificates \
 && addgroup --gid "$GID" "$USER" \
 && adduser \
    --disabled-password \
    --gecos "" \
    --home "$(pwd)" \
    --ingroup "$USER" \
    --no-create-home \
    --uid "$UID" \
    "$USER" \
 && chown -R lpw:lpw /srv/ldap-passwd-webui

WORKDIR /srv/ldap-passwd-webui
RUN pip install -r requirements.txt

USER lpw

CMD [ "python", "app.py" ]
