This repo is the laziest setup of a local Kong API container and Cassandra DB backend.
The Dockerfile contains the installation of the JWT unpacker via luarocks.

Instructions:
1. Clone this repo.
2. Run kong.sh
3. To kill : docker-compose kill

Notes:
The cassandra container may take a while to start, if your computers slow, modify kong.sh to increase 'sleep 15' as required.
