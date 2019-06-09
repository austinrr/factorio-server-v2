#!/bin/sh
set -euo pipefail

S3=/opt/factorio/s3
mkdir -p "$S3"/saves
mkdir -p "$S3"/config
mkdir -p "$S3"/mods
mkdir -p "$S3"/scenarios
mkdir -p "$S3"/logs

# local variables
SERVER=/opt/factorio/bin/x64/factorio
SAVES="$S3"/saves
MODS="$S3"/mods
SCENARIOS="$S3"/scenarios
CONFIG="$S3"/config
SU_EXEC="su-exec factorio"
NRSAVES=$( find -L "$SAVES" -mindepth 1 -iname \*.zip | wc -l )

# Copy default settings for those not found and generate map if a save is not found
function copyDefaults {
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
	fi

	# if [ "$NRSAVES" -eq 0 ]; then -- no idea why this does not work but the following does
	if [ "$( find -L "$SAVES" -mindepth 1 -iname \*.zip | wc -l )" -eq 0 ]; then
		echo "No save files found, generating new map"

		$SU_EXEC "$SERVER" \
			--create "$SAVES/_autosave1.zip" \
			--map-gen-settings "$CONFIG/map-gen-settings.json" \
			--map-settings "$CONFIG/map-settings.json"
	fi

	NRTMPSAVES=$( find -L "$SAVES" -iname \*.tmp.zip -mindepth 1 | wc -l )
	if [ "$NRTMPSAVES" -gt 0 ]; then
		# Delete incomplete saves (such as after a forced exit)
		rm -f "$SAVES"/*.tmp.zip
	fi
}

# Wait for files to download from S3
function waitOnS3 {
	for retries in `seq 1 12`; do
		if [ "$( find -L "$SAVES" -mindepth 1 -iname \*.zip | wc -l )" -eq 0 ]; then
			echo "Waiting 10s..."
			sleep 10s
		else
			echo "Save files found!"
			break;
		fi
	done
}

function start {
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

waitOnS3
copyDefaults
start

trap stop SIGHUP SIGINT SIGTERM