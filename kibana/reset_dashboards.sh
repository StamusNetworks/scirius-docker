#!/bin/bash

cd /opt/selks/scirius/

reset_dashboards() {
	for I in $(seq 0 20); do
		python manage.py kibana_reset 2>/dev/null && return 0
		echo "Kibana dashboards reset: Elasticsearch not ready, retrying in 10 seconds."
		sleep 10
	done
	return -1
}


if [ ! -e "/var/lib/misc/kibana_dashboards" ]; then
	reset_dashboards && touch "/var/lib/misc/kibana_dashboards"
fi
