#!/bin/sh

# is docker installed?
if ! [ -x "$(command -v docker)" ]; then
	echo 'Warn: Docker is not installed'

	sudo yum install -y docker docker-compose
fi

# shutdown existing factorio server
docker-compose down

# verify docker compose yml exists
if ! [ -f /tmp/docker-compose-yml ]; then
	echo 'Warn: docker-compose.yml file was not copied, try re-running deploy in circleci'
	exit 1
fi

# start server
docker-compose up