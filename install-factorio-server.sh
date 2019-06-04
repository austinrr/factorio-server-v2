#!/bin/sh

# is docker installed ?
if ! [ -x "$(command -v docker)" ]; then
	echo 'Warn: Docker is not installed, attempting to install'

	sudo yum install -y docker docker-compose
	wait &!
fi

# is docker service running ?
if ! ( systemctl -q is-active docker ); then
	echo 'Warn: Docker is not running, attempting to start'
	sudo service docker start
	wait &!
fi

# verify docker compose yml exists
if ! [ -f /tmp/docker-compose.yml ]; then
	echo 'Error: docker-compose.yml file was not copied, try re-running deploy in circleci'
	exit 1
fi

# shutdown existing factorio server
docker-compose -f /tmp/docker-compose.yml down
wait &1

# start server
docker-compose -f /tmp/docker-compose.yml up