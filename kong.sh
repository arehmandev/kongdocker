docker build -t abdulkong .
docker-compose up -d
echo "Waiting for cassandra to boot"
sleep 15 # modify depending how slow your laptop is
echo "Done, run docker-compose up -d if kong didn't load"
echo "Run docker-compose kill to destroy containers"
