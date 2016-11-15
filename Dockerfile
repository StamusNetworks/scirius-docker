FROM debian:latest

ENV VERSION 1.1.13
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y wget python-pip python-dev git gcc gunicorn tcpdump
ADD stamus-packages.list /etc/apt/sources.list.d/
WORKDIR /tmp/
RUN wget -O stamus.key -q http://packages.stamus-networks.com/packages.stamus-networks.com.gpg.key
RUN apt-key add stamus.key
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y suricata
RUN wget https://github.com/StamusNetworks/scirius/archive/scirius-${VERSION}.tar.gz
RUN mkdir -p /opt/selks/sciriusdata
WORKDIR /opt/selks
RUN tar zxf /tmp/scirius-${VERSION}.tar.gz
RUN ln -sf /opt/selks/scirius-scirius-${VERSION} /opt/selks/scirius
WORKDIR /opt/selks/scirius
RUN pip install --upgrade six
RUN pip install -r requirements.txt
RUN ln -s /etc/scirius/local_settings.py /opt/selks/scirius/scirius/
ADD django/scirius.json /tmp/
ADD django/scirius.sh /opt/selks/bin/
RUN chmod ugo+x /opt/selks/bin/scirius.sh
ADD kibana/reset_dashboards.sh /opt/selks/bin/
RUN chmod ugo+x /opt/selks/bin/reset_dashboards.sh
RUN git clone https://github.com/StamusNetworks/KTS.git  /opt/kibana-dashboards/
RUN pip install elasticsearch-curator

ENTRYPOINT ["/opt/selks/bin/scirius.sh"]
