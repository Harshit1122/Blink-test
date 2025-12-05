#!/bin/bash
set -e

echo 'Waiting for PostgreSQL...'
while ! pg_isready -h postgres -p 5432; do
  sleep 1
done

echo 'Waiting for Redis...'
while ! redis-cli -h redis ping | grep -q PONG; do
  sleep 1
done

echo 'All databases ready!'

exec "$@"