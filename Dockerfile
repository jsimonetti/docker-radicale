FROM jsimonetti/alpine-edge:latest

ARG VERSION=3.0.4
ARG UID=2999
ARG GID=2999

RUN apk add --no-cache --virtual=build-dependencies \
        gcc \
        libffi-dev \
        musl-dev \
        python3-dev \
    && apk add --no-cache \
        curl \
        git \
        python3 \
        shadow \
        su-exec \
        py3-pip \
    && python3 -m pip install --upgrade pip \
    && python3 -m pip install radicale==$VERSION passlib[bcrypt] \
    && python3 -m pip install --upgrade git+https://github.com/Unrud/RadicaleInfCloud \
    && python3 -m pip install --upgrade git+https://github.com/Unrud/RadicaleIMAP \
    && apk del --purge build-dependencies \
    && addgroup -g $GID radicale \
    && adduser -D -s /bin/false -H -u $UID -G radicale radicale \
    && mkdir -p /config /data \
    && chmod -R 770 /data \
    && chown -R radicale:radicale /data

COPY config /config/config

HEALTHCHECK --interval=30s --retries=3 CMD curl --fail http://localhost:5232 || exit 1

EXPOSE 5232

COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["tini", "--", "docker-entrypoint.sh"]
CMD ["radicale", "--config", "/config/config"]
