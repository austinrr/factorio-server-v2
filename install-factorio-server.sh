#!/bin/sh

# -------------------------------------------------------------------
# Problems:
# docker-compose will not be installed, see https://www.hostinger.com/tutorials/how-to-install-docker-compose-centos-7/
# docker service will be running but not useable by ec2-user, the following must be run
# "sudo usermod -a -G docker ec2-user" and the machine rebooted
# -------------------------------------------------------------------

# set env vars
echo 'Setting ENV vars ...'
curl -s http://169.254.169.254/latest/user-data > /tmp/user-data.txt
export AWS_USER_NAME="$(cut -s -f 1 -d ',' /tmp/user-data.txt)"
export AWS_ACCESS_KEY="$(cut -s -f 2 -d ',' /tmp/user-data.txt)"
export AWS_SECRET_KEY="$(cut -s -f 3 -d ',' /tmp/user-data.txt)"

# is docker installed ?
if ! [ -x "$(command -v docker)" ]; then
	echo 'Warn: Docker is not installed, attempting to install'
	sudo yum install -y docker docker-compose

else
	/usr/bin/printf "\xE2\x9C\x94 docker is installed\n"
fi

# is docker service running ?
if ! ( systemctl -q is-active docker ); then
	echo 'Warn: Docker is not running, attempting to start'
	sudo service docker start
else
	/usr/bin/printf "\xE2\x9C\x94 docker is running\n"
fi

# verify docker compose yml exists
if ! [ -f /tmp/server/docker-compose.yml ]; then
	echo 'Error: docker-compose.yml file was not copied, try re-running deploy in circleci'
	exit 1
else
	/usr/bin/printf "\xE2\x9C\x94 docker compose yml file exists\n"
fi

# shutdown existing factorio server
docker-compose -f /tmp/server/docker-compose.yml down
/usr/bin/printf "\xE2\x9C\x94 docker-compose down\n"

# start server
docker-compose -f /tmp/server/docker-compose.yml up --detach
/usr/bin/printf "\xE2\x9C\x94 docker-compose up\n"