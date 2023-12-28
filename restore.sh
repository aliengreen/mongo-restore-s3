
#! /bin/sh

set -eo pipefail

if [ "${S3_ACCESS_KEY_ID}" = "**None**" ]; then
  echo "You need to set the S3_ACCESS_KEY_ID environment variable."
  exit 1
fi

if [ "${S3_SECRET_ACCESS_KEY}" = "**None**" ]; then
  echo "You need to set the S3_SECRET_ACCESS_KEY environment variable."
  exit 1
fi

if [ "${S3_BUCKET}" = "**None**" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

# if [ "${MONGODB_DATABASE}" = "**None**" -a "${MONGODB_BACKUP_ALL}" != "true" ]; then
#   echo "You need to set the MONGODB_DATABASE environment variable."
#   exit 1
# fi

if [ "${MONGODB_HOST}" = "**None**" ]; then
  if [ -n "${MONGODB_PORT_27017_TCP_ADDR}" ]; then
    MONGODB_HOST=$MONGODB_PORT_27017_TCP_ADDR
    MONGODB_PORT=$MONGODB_PORT_27017_TCP_PORT
  else
    echo "You need to set the MONGODB_HOST environment variable."
    exit 1
  fi
fi

if [ "${MONGODB_USER}" != "**None**" ]; then
  echo "MONGODB_USER environment variable is not supported"
  exit 1
fi

if [ "${MONGODB_PASSWORD}" != "**None**" ]; then
  echo "MONGODB_PASSWORD environment variable is not supported"
  exit 1
fi

if [ "${S3_ENDPOINT}" == "**None**" ]; then
  AWS_ARGS=""
else
  AWS_ARGS="--endpoint-url ${S3_ENDPOINT}"
fi

# env vars needed for aws tools
export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$S3_REGION

export PGPASSWORD=$MONGODB_PASSWORD
MONGODB_HOST_OPTS="--host $MONGODB_HOST:$MONGODB_PORT"
# -U $MONGODB_USER $MONGODB_EXTRA_OPTS"

echo "Finding latest backup"

LATEST_BACKUP=$(aws $AWS_ARGS s3 ls s3://$S3_BUCKET/$S3_PREFIX/ | sort | tail -n 1 | awk '{ print $4 }')

echo "Fetching ${LATEST_BACKUP} from S3"

aws $AWS_ARGS s3 cp s3://$S3_BUCKET/$S3_PREFIX/${LATEST_BACKUP} dump.gz

echo "Restoring ${LATEST_BACKUP}"

mongorestore $MONGODB_HOST_OPTS --archive --gzip --nsInclude=*.* --drop < dump.gz

echo "Restore complete"