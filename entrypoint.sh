#!/bin/bash
set -e

echo 'Waiting for PostgreSQL...'
while ! pg_isready -h $POSTGRES_HOST -p 5432; do
  sleep 1
done

echo 'Waiting for Redis...'
while ! redis-cli -h $REDIS_HOST ping | grep -q PONG; do
  sleep 1
done

echo 'All databases ready!'

echo 'Initializing database and running migrations...'
faraday-manage migrate

echo 'Creating database tables...'
faraday-manage create-tables

echo 'Loading seed data...'
cd faraday && python manage.py loaddata fixtures/*.json

exec "$@"