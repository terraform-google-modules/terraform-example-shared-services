#!/bin/bash
set -eu

# Install and enable Apache HTTP server on CentOS
yum -y update
yum install -y httpd
systemctl start httpd
systemctl enable httpd
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --reload

cat > /var/www/html/index.html <<EOF
${index_page}
EOF
