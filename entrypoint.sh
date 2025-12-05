#!/bin/bash
set -e

echo 'Waiting for MySQL...'
while ! mysqladmin ping -h mysql --silent; do
  sleep 1
done

echo 'All databases ready!'

exec "$@"