For a local kong environment via docker-compose:

To initially setup environment:

1. Run kong.sh
2. If 1 didn't work, run "docker rm -f abdulkong && docker rm -f kong-database"
3. Retry step 1.

To kill environment:

docker-compose kill

To rebring up environment in future:

docker-compose up
