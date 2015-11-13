# Jessie

apt-get update && apt-get install -y \
	adduser \
  libreadline-gplv2-dev \ 
  build-essential \
  ca-certificates \
	cron \
	curl \
	dialog\
  debconf-utils \
  libarchive-dev \
	libav-tools \
	libjsoncpp-dev \
	libpcre3-dev \
	git \
  g++ \
  htop \
  locate \
	libfreetype6-dev \
  libmcrypt-dev \
  libcurl4-gnutls-dev \
  libpng12-dev \
  libreadline-gplv2-dev \ 
  libssh2-php \
	libtinyxml-dev \
	libudev1 \
	libxml2 \
	locales \
	miniupnpc \
	mysql-client \
	mysql-common \
	mysql-server \
	mysql-server-core \
  net-tools \
	nginx-common \
	nginx-full \
	nodejs \
	ntp \
	npm \
	openssh-server \
	php5-cli \
	php5-common \
	php5-curl \
	php5-dev \
	php5-fpm \
	php5-json \
	php5-mysql \
	php-pear \
  python \
	python-serial \
	sudo \
	supervisor \
	systemd	 \
  tar \
  telnet \
  tzdata \
  unzip \ 
  usb-modeswitch \
  usbutils \
  vim \
  wget

# Configure locale  
unzip \ usb-modeswitch RUN dpkg-reconfigure locales && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8

# Configure TimeZone
rm -rf /var/lib/apt/lists/* &&\ echo "Europe/Berlin" > /etc/timezone &&\ dpkg-reconfigure -f noninteractive tzdata

# Configure BASH
echo 'alias ls="ls -lah --color=auto"' >> /etc/bash.bashrc

# Configure SSH & securiy
sed -i "s/PermitRootLogin without-password/PermitRootLogin no/g" /etc/ssh/sshd_config
sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

# Configure SUDO
echo "www-data ALL=(ALL) NOPASSWD: ALL" | (EDITOR="tee -a" visudo)

apt-get autoremove



# Configuration Certificate SSL RUN openssl genrsa -out $hostname.key 2048
RUN openssl req \
        -new \
        -subj "/C=FR/ST=France/L=Lyon/O=jeedom/OU=JE/CN=jeedom" \
        -key jeedom.key \
        -out jeedom.csr && \
   openssl x509 -req -days 9999 -in jeedom.csr -signkey jeedom.key -out jeedom.crt

RUN mkdir /etc/nginx/certs && \
        cp jeedom.key /etc/nginx/certs && \
        cp jeedom.crt /etc/nginx/certs && \
        rm jeedom.key jeedom.crt
              
COPY nginx_default_ssl /etc/nginx/sites-enabled/default_ssl

# modification de la configuration PHP pour un temps d'exécution allongé et le traitement de fichiers lourds RUN sed -i "s/max_execution_time = 30/max_execution_time = 300/g" /etc/php5/fpm/php.ini
sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 1G/g" /etc/php5/fpm/php.ini
sed -i "s/post_max_size = 8M/post_max_size = 1G/g" /etc/php5/fpm/php.ini

echo "www-data ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
