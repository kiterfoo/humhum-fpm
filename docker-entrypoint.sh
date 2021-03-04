#!/bin/sh
set -e

if [ ! -e index.php ]; then
	tar cf - --one-file-system -C /usr/src/humhub . | tar xf -
	chown -R www-data:www-data .
fi
crond -b -d 8
exec "$@"
