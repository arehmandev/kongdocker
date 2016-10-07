docker build --no-cache -t abdulkong .
docker build --no-cache -t abdulphpserver PHPserver/
docker-compose up -d
echo "Waiting for cassandra to boot"
sleep 22 # modify depending how slow your laptop is
docker-compose up -d
echo "Done, run docker-compose up -d if kong didn't load"
echo "Run docker-compose kill to destroy containers"
echo "To connect to mysql (password = test)":
echo " mysql -u root -h $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${CID} mysqldatabase) -p"
