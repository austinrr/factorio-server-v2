#!/bin/sh
set -euo pipefail

S3=/opt/factorio/s3
mkdir -p "$S3"/saves
mkdir -p "$S3"/config
mkdir -p "$S3"/mods
mkdir -p "$S3"/scenarios
mkdir -p "$S3"/logs

SERVER=/opt/factorio/bin/x64/factorio
SAVES="$S3"/saves
MODS="$S3"/mods
SCENARIOS="$S3"/scenarios
CONFIG="$S3"/config

function setup {
	SU_EXEC=""

	if [ ! -f "$CONFIG/server-settings.json" ]; then
	# Copy default settings if server-settings.json doesn't exist
	cp /opt/factorio/data/server-settings.example.json "$CONFIG/server-settings.json"
	fi

	if [ ! -f "$CONFIG/map-gen-settings.json" ]; then
	# Copy default map generation setting if map-gen-settings.json doesn't exist
	cp /opt/factorio/data/map-gen-settings.example.json "$CONFIG/map-gen-settings.json"
	fi

	if [ ! -f "$CONFIG/map-settings.json" ]; then
	# Copy default map settings if map-setting.json doesn't exist
	cp /opt/factorio/data/map-settings.example.json "$CONFIG/map-settings.json"
	fi

	if [ "$(id -u)" = '0' ]; then
	# Update the User and Group ID based on the PUID/PGID variables
	usermod -o -u "$PUID" factorio
	groupmod -o -g "$PGID" factorio
	# Take ownership of factorio data if running as root
	chown -R factorio:factorio "$S3"
	# Drop to the factorio user
	SU_EXEC="su-exec factorio"
	fi

	NRSAVES=$( find -L "$SAVES" -mindepth 1 -iname \*.zip | wc -l )
	if [ "$NRSAVES" -eq 0 ]; then
	# Generate a new map if no save ZIPs exist
	$SU_EXEC "$SERVER" \
		--create "$SAVES/_autosave1.zip" \
		--map-gen-settings "$CONFIG/map-gen-settings.json" \
		--map-settings "$CONFIG/map-settings.json"
	fi
}

function start {
	setup

	echo "Starting server..."
	exec $SU_EXEC "$SERVER" \
		--port "$PORT" \
		--start-server-load-latest \
		--server-settings "$CONFIG/server-settings.json" \
		--server-banlist "$CONFIG/server-banlist.json" \
		--server-whitelist "$CONFIG/server-whitelist.json" \
		# --server-adminlist "$CONFIG/server-adminlist.json" \
		--rcon-port "$RCON_PORT" \
		--rcon-password "$(cat "$CONFIG/rconpw")" \
		--server-id "$CONFIG/server-id.json"
}

function stop {
	echo "Stopping server..."
	exit 0
}

start

trap stop SIGHUP SIGINT SIGTERM