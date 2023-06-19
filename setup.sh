#!/bin/bash
set -e
if [[ $EUID -ne 0 ]]; then
  echo "* This script must be executed with root privileges (sudo)." 1>&2
  exit 1
fi
echo "      Welcome to AutoSetupOracle"
echo "With this script you can setup your server, created by SuperHori modified by mihaidev-cloud"
read -p "Press any key to start installing ..."
cd /etc/ssh
rm sshd_config
sudo echo " 
# sshd modified by autosetuporacle script do not modified only if you know what are you doing!

# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.

# This sshd was compiled with PATH=/usr/bin:/bin:/usr/sbin:/sbin

# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented.  Uncommented options override the
# default value.

Include /etc/ssh/sshd_config.d/*.conf

Port 22
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

#HostKey /etc/ssh/ssh_host_rsa_key
#HostKey /etc/ssh/ssh_host_ecdsa_key
#HostKey /etc/ssh/ssh_host_ed25519_key

# Ciphers and keying
#RekeyLimit default none

# Logging
#SyslogFacility AUTH
#LogLevel INFO

# Authentication:

#LoginGraceTime 2m
#root can be dangerous using it since has full privileges and is unprofessional.
PermitRootLogin no 
#StrictModes yes
#MaxAuthTries 6
#MaxSessions 10

#PubkeyAuthentication yes

# Expect .ssh/authorized_keys2 to be disregarded by default in future.
#AuthorizedKeysFile	.ssh/authorized_keys .ssh/authorized_keys2

#AuthorizedPrincipalsFile none

#AuthorizedKeysCommand none
#AuthorizedKeysCommandUser nobody

# For this to work you will also need host keys in /etc/ssh/ssh_known_hosts
#HostbasedAuthentication no
# Change to yes if you don't trust ~/.ssh/known_hosts for
# HostbasedAuthentication
#IgnoreUserKnownHosts no
# Don't read the user's ~/.rhosts and ~/.shosts files
#IgnoreRhosts yes

# To disable tunneled clear text passwords, change to no here!
PasswordAuthentication yes
#PermitEmptyPasswords no

# Change to yes to enable challenge-response passwords (beware issues with
# some PAM modules and threads)
ChallengeResponseAuthentication no

# Kerberos options
#KerberosAuthentication no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes
#KerberosGetAFSToken no

# GSSAPI options
#GSSAPIAuthentication no
#GSSAPICleanupCredentials yes
#GSSAPIStrictAcceptorCheck yes
#GSSAPIKeyExchange no

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the ChallengeResponseAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via ChallengeResponseAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and ChallengeResponseAuthentication to 'no'.
UsePAM yes

#AllowAgentForwarding yes
#AllowTcpForwarding yes
#GatewayPorts no
X11Forwarding yes
#X11DisplayOffset 10
#X11UseLocalhost yes
#PermitTTY yes
PrintMotd no
#PrintLastLog yes
#TCPKeepAlive yes
#PermitUserEnvironment no
#Compression delayed
#ClientAliveInterval 0
#ClientAliveCountMax 3
#UseDNS no
#PidFile /var/run/sshd.pid
#MaxStartups 10:30:100
#PermitTunnel no
#ChrootDirectory none
#VersionAddendum none

# no default banner path
#Banner none

# Allow client to pass locale environment variables
AcceptEnv LANG LC_*

# override default of no subsystems
Subsystem	sftp	/usr/lib/openssh/sftp-server

# Example of overriding settings on a per-user basis
#Match User anoncvs
#	X11Forwarding no
#	AllowTcpForwarding no
#	PermitTTY no
#	ForceCommand cvs server
" >> /etc/ssh/sshd_config

systemctl restart ssh
systemctl restart sshd
echo "Let's create a username with sudo privileges"
echo "enter your name!"
read userchosen
sudo adduser $userchosen
echo "creating sudo privilege for user"
sudo add user $userchosen sudo
sudo su $userchosen
echo "You are logged as $userchosen please be aware in case if the execution needs human action!"
echo "want to install basic apps and configure firewall and disable iptables? Nginx Webserver, Certbot SSL, mysql(mariadb) type yes or press enter for exit"
echo "are you agree to install? type yes or press enter to cancel"

read answer
if [ "$answer" ]; then 

echo $answer, "lets get started!"

sudo apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
add-apt-repository ppa:redislabs/redis -y
apt-add-repository universe
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash
apt -y install php8.1 php8.1-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} nginx certbot python3-certbot-nginx iptables mariadb-server tar unzip git iptables-persistent
sudo apt update
sudo apt -y upgrade
echo "adding ssh port"
sudo ufw allow 22 
sudo ufw allow 'Nginx Full'
sudo ufw allow 3306 
echo "y" | sudo ufw enable
echo "you can open port too! just type sudo ufw allow portnumber"
echo "we activated the firewall and managed it I also recommend human supervision here!"
echo "disabling iptables"
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -F
sudo iptables -X
iptables-save > /etc/iptables/rules.v4
echo "Ok that's it if you encounter any problems make sure to report them by creating a issue on github repository"
echo "Original Project by superhori, modified by mihaidev-cloud :D"
exit
else
echo "Ok that's it if you encounter any problems make sure to report them by creating a issue on github repository"
echo "Original Project by superhori, modified by mihaidev-cloud :D"
exit
fi
