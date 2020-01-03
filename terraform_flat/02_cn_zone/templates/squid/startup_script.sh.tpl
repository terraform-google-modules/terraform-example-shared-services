#!/bin/bash
set -eu

yum -y update
yum -y install squid

cat > /etc/squid/squid.conf <<EOF
${squid_conf}
EOF

cat > /etc/squid/whitelist.txt <<EOF
${whitelist_txt}
EOF

systemctl start squid
systemctl enable squid
systemctl status squid

# Install the stackdriver Logging agent so squid proxy logs are sent to stackdriver
curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh
bash install-logging-agent.sh
cat << EOF > /etc/google-fluentd/config.d/squid.conf
<source>
  @type tail
  format none
  path /var/log/squid/access.log
  pos_file /var/lib/google-fluentd/pos/squid-access.pos
  read_from_head true
  tag squid-access
</source>
EOF
systemctl restart google-fluentd