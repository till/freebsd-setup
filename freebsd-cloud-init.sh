#!/bin/sh

# update system
cat <<EOT > /etc/make.conf
NO_BIND
NO_CVS
NO_SENDMAIL
NO_X
WITHOUT_X11
WITH_PKGNG=yes
DEFAULT_VERSIONS+= ssl=libressl
WITH_OPENSSL_PORT=yes
OPENSSL_PORT=security/libressl
EOT

pkg update -fq
pkg upgrade -yq
pkg install -yq wget
pkg install -yq git

# rsyslogd setup
service syslogd stop
pkg install -yq rsyslog

cat <<EOT >> /etc/rc.conf

syslogd_enable="NO"
rsyslogd_enable="YES"
rsyslogd_pidfile="/var/run/syslog.pid"
EOT

cat <<EOT > /usr/local/etc/rsyslog.conf
module(load="immark")   # provides --MARK-- message capability
module(load="imuxsock") # provides support for local system logging
module(load="imklog")   # kernel logging

EOT

cat /etc/syslog.conf >> /usr/local/etc/rsyslog.conf

service rsyslogd start

# ntp
cat <<EOT >> /etc/rc.conf

ntpd_enable="YES"
ntpd_sync_on_start="YES"
EOT

service ntpd start

# firewall & hardening
cat <<EOT >> /etc/rc.conf

firewall_enable="YES"
firewall_quiet="YES"
firewall_type="workstation"
firewall_myservices="ssh http https"
firewall_allowservices="any"
firewall_logdeny="YES"

sendmail_enable="NONE"

portmap_enable="NO"
inetd_enable="NO"
clear_tmp_enable="YES"
icmp_drop_redirect="YES"
icmp_log_redirect="YES"
# log_in_vain="YES"
# tcp_drop_synfin="YES"
EOT

cat <<EOT >> /etc/sysctl.conf

security.bsd.see_other_uids=0
net.inet.ip.fw.verbose_limit=5

net.inet.tcp.blackhole=2
net.inet.udp.blackhole=1
net.inet.ip.random_id=1
EOT

sysctl security.bsd.see_other_uids=0
sysctl net.inet.ip.fw.verbose_limit=5
sysctl net.inet.tcp.blackhole=2
sysctl net.inet.udp.blackhole=1
sysctl net.inet.ip.random_id=1

service ipfw start

pkg install -yq lockdown
