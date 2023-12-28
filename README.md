# mongo-restore-s3

[![Docker Hub Link][docker-img]][docker-url]

Restore MongoDB from S3 it based on https://github.com/schickling/dockerfiles/tree/master/postgres-restore-s3



## Usage

Run using `docker run`  command, which is an alternative to using Docker Compose to run a Docker container. This command is designed to run the `aliengreenllc/mongo-restore-s3` container with environment variables set for configuration. 

```shell
docker run \
  -e S3_ENDPOINT=https://ams3.digitaloceanspaces.com \
  -e S3_ACCESS_KEY_ID=key \
  -e S3_SECRET_ACCESS_KEY=secret \
  -e S3_BUCKET=buketname \
  -e S3_PREFIX=backup \
  -e MONGODB_HOST=mdb-host \
  aliengreenllc/mongo-restore-s3
```

> NOTE: you can specify network with parameter `--network=name`

- `S3_ENDPOINT`: The URL of the S3 endpoint, in this case, [https://ams3.digitaloceanspaces.com](https://ams3.digitaloceanspaces.com/).
- `S3_ACCESS_KEY_ID`: The access key ID for connecting to the specified S3 bucket.
- `S3_SECRET_ACCESS_KEY`: The secret access key associated with the access key ID.
- `S3_BUCKET`: The name of the S3 bucket where the backups will be stored.
- `S3_PREFIX`: The prefix or folder name within the S3 bucket where the backups will be stored.
- `MONGODB_HOST`: The host address of the MongoDB instance, in this case, `mdb-host`.
- `aliengreenllc/mongo-restore-s3`: The Docker image to be run.

### Endpoints for S3

An Endpoint is the URL of the entry point for an AWS web service or S3 Compitable Storage Provider.

You can specify an alternate endpoint by setting `S3_ENDPOINT` environment variable like `protocol://endpoint` e.g. [https://ams3.digitaloceanspaces.com](https://ams3.digitaloceanspaces.com/) for DigitalOcean Space.

>  NOTE: S3 Compitable Storage Provider requires `S3_ENDPOINT` environment variable



Docker composer:

```yaml
backdb-restore:
    container_name: backdb-restore
    image: aliengreenllc/mongo-restore-s3
    environment:
      S3_ENDPOINT: "https://ams3.digitaloceanspaces.com"
      S3_ACCESS_KEY_ID: "key"
      S3_SECRET_ACCESS_KEY: "secret"
      S3_BUCKET: "buketname"
      S3_PREFIX: "backup"
      MONGODB_HOST: "mdb-host"
    networks:
      - db_network
```

To see all available versions: https://hub.docker.com/r/aliengreenllc/mongo-restore-s3/tags/



## Limitations

This is made to restore a backup made from mongo-backup-s3, if you backup came from somewhere else please check your format.

- There is no support for database usernames and passwords, but it can be easily added. Unfortunately, I don't have the time to test and implement this functionality at the moment.

- Your s3 bucket *must* only contain backups which you wish to restore - it will always grabs the 'latest' based on unix sort with no filtering
- They must be gzip encoded text sql files
- If your bucket has more than a 1000 files the latest may not be restore, only one s3 ls command is made



## License

[MIT](LICENSE)

[docker-img]: https://img.shields.io/badge/docker-ready-blue.svg
[docker-url]: https://hub.docker.com/r/aliengreenllc/mongo-restore-s3