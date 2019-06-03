FROM frolvlad/alpine-glibc

LABEL maintainer="austin.dev@outlook.com"
LABEL description="A Factorio Server"
LABEL version="0.1"

ENV PORT=34197 \
	RCON_PORT=27015 \
	VERSION=0.16.51 \
	PUID=845 \
	PGID=845 \
	USER=factorio \
	GROUP=factorio \
	SAVES=/opt/factorio/s3/saves \
	CONFIG=/opt/factorio/s3/config \
	MODS=/opt/factorio/s3/mods \
	SCENARIOS=/opt/factorio/s3/scenarios

## update CentOS and clean
RUN mkdir -p /opt/factorio/s3 && \
	apk add --update --no-cache pwgen su-exec binutils libintl shadow && \
	apk add --update --no-cache --virtual .build-deps curl

# download and setup factorio assets
RUN	curl -sSL "https://www.factorio.com/get-download/$VERSION/headless/linux64" \
	-o /tmp/factorio_headless_x64_$VERSION.tar.xz && \
	echo "downloaded /tmp/factorio_headless_x64_$VERSION.tar.xz" && \
	tar xf "/tmp/factorio_headless_x64_$VERSION.tar.xz" --directory /opt && \
	chmod ugo=rwx /opt/factorio && \
	rm "/tmp/factorio_headless_x64_$VERSION.tar.xz" && \
	ln -s "$SAVES" /opt/factorio/saves && \
	ln -s "$CONFIG" /opt/factorio/config && \
	ln -s "$SCENARIOS" /opt/factorio/scenarios && \
	ln -s "$MODS" /opt/factorio/mods && \
	addgroup -g "$PGID" -S "$GROUP" && \
	adduser -u "$PUID" -G "$GROUP" -s /bin/sh -SDH "$USER" && \
	chown -R "$USER":"$GROUP" /opt/factorio && \
	apk del .build-deps

ADD /scripts/* /opt/factorio/scripts/

EXPOSE ${PORT}/udp ${RCON_PORT}/tcp

ENTRYPOINT [ "/opt/factorio/scripts/start-server.sh" ]