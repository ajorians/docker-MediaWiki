# docker-MediaWiki
A Docker image build of MediaWiki.

To build (run as root): docker build -t mediawiki .

You can run it with Docker-Compose file with:
docker-compose up -d

Note it first has the LocalSettings.php file commented out.  After setup send this file, go down:
docker-compose down

Do a quick edit to docker-compose.yml and then go back up with:
docker-compose up -d

You do need a database (not included).

Hope that help!
