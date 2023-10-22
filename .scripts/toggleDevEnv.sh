#!/bin/sh

# Set DOCKER_HOST directly
DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

# Log file path
log_file="$HOME/.scripts/script_log.txt"

# Define the names of your Docker containers
postgres_container="my_postgres"
mongo_container="my_mongo"

# Function for logging
log() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >>"$log_file"
}

# Check if the containers are running
if docker ps --format "{{.Names}}" | grep -q "$postgres_container" && docker ps --format "{{.Names}}" | grep -q "$mongo_container"; then
	log "Dev environment is already running."
	cd "$HOME/extras/.dockervolumes/" && docker-compose down >>"$log_file" 2>&1
	if [ $? -eq 0 ]; then
		log "Dev environment is now off."
		notify-send "Dev environment is off"
	else
		log "Error: Failed to stop the Dev environment."
		notify-send "Error: Failed to stop the Dev environment"
	fi
else
	log "Dev environment is not running."
	cd "$HOME/extras/.dockervolumes/" && docker-compose up -d >>"$log_file" 2>&1
	if [ $? -eq 0 ]; then
		log "Dev environment is now on."
		notify-send "Dev environment is on"
	else
		log "Error: Failed to start the Dev environment."
		notify-send "Error: Failed to start the Dev environment"
	fi
fi
