#!/bin/bash

cd /opt/selks/scirius/

migrate_db() {
	python manage.py migrate
	python manage.py collectstatic  --noinput
}

create_db() {
	python manage.py migrate --noinput
	python manage.py loaddata /tmp/scirius.json
	python manage.py createcachetable my_cache_table
	python manage.py addsource "ETOpen Ruleset" https://rules.emergingthreats.net/open/suricata-3.0/emerging.rules.tar.gz http sigs
	python manage.py addsource "SSLBL abuse.ch" https://sslbl.abuse.ch/blacklist/sslblacklist.rules http sig
	python manage.py addsource "PT Research Ruleset" https://github.com/ptresearch/AttackDetection/raw/master/pt.rules.tar.gz http sigs
	python manage.py defaultruleset "Default SELKS ruleset"
	python manage.py disablecategory "Default SELKS ruleset" stream-events
	python manage.py addsuricata suricata "Suricata on SELKS" /etc/suricata/rules "Default SELKS ruleset"
	python manage.py updatesuricata
	python manage.py collectstatic --noinput
}

start() {
	webpack
	cd hunt
	npm run build
	cd ..
	python manage.py collectstatic --noinput
	echo "Starting scirius server."
	gunicorn -w $(($(nproc --all)*2+1)) -t 120 -b 0.0.0.0:8000 scirius.wsgi
}

# update requirements if needed
pip install -r requirements.txt

if [ ! -e "/sciriusdata/scirius.sqlite3" ]; then
	create_db
else
	migrate_db
fi

/opt/selks/bin/reset_dashboards.sh &

start
