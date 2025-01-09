# SQLtutor Docker Deployment

Deploy [SQLtutor](https://savannah.gnu.org/projects/sqltutor/) using Docker.

## Requirements

* [Docker](https://www.docker.com/)

## Deploy

1. Create `env` file:

```
POSTGRES_PASSWORD=20sqltutor21
SQLTUTOR_DATABASE=sqltutor
SQLTUTOR_WWW_USER=sqlquiz
SQLTUTOR_PASSWORD=sqlkrok
SQLTUTOR_WWW_EXEC=sqlexec
SQLTUTOR_PASSEXEC=sqlkrok
```

2. Deyploy by `docker-compose`:

```bash
docker compose up
```

3. Open http://localhost:8085

### Re-deploy from scratch

Stop services:

```
docker compose down
```

Remove DB volume:

```
docker volume rm sqltutor-docker_db_data
```
