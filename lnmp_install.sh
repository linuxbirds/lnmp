#!/bin/bash
# Author:GuoZi
# Email:chenqiin49@gmail.com
# Website:http://www.guoziweb.com/
# Test on CentOS 6.x,for other Linux,pls test by yourself
# Not support deb linux ,e.g. Ubuntu 
# Default mysql root password

NGINX_VERSION='nginx-1.8.0'
MYSQL_ROOT_PASSWD='www.guoziweb.com'
PWD_DIR=`pwd`

function func_install_php_mysql()
{
    yum install php-fpm php-cli php-mysql mysql-server -y
    yum install gcc automake autoconf pcre pcre-devel zlib zlib-devel openssl openssl-devel -y
    mysqladmin -uroot password "$MYSQL_ROOT_PASSWD"
}
function func_install_nginx()
{
    useradd -s /sbin/nologin www

    if [ ! -f "${NGINX_VERSION}.tar.gz" ];then
        wget http://nginx.org/download/${NGINX_VERSION}.tar.gz
    fi
tar zxf ${NGINX_VERSION}.tar.gz
cd $NGINX_VERSION
./configure \
--prefix=/etc/nginx \
--sbin-path=/usr/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/tmp/nginx/error.log \
--http-log-path=/tmp/nginx/access.log \
--pid-path=/var/run/nginx.pid \
--lock-path=/var/run/nginx.lock \
--with-pcre \
--http-client-body-temp-path=/tmp/nginx/client_temp \
--http-proxy-temp-path=/tmp/nginx/proxy_temp \
--http-fastcgi-temp-path=/tmp/nginx/fastcgi_temp \
--http-uwsgi-temp-path=/tmp/nginx/uwsgi_temp \
--http-scgi-temp-path=/tmp/nginx/scgi_temp \
--user=www \
--group=www \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_stub_status_module \
--with-http_auth_request_module \
--with-mail \
--with-mail_ssl_module \
--with-file-aio \
--with-http_spdy_module
make
make install
}
function func_install_conf()
{
    if [ -f "${PWD_DIR}/lnmp_config.tgz" ];then
        tar zxvf ${PWD_DIR}/lnmp_config.tgz -C /
    fi
    iptables -I INPUT -p tcp --dport 80 -j ACCEPT
}
function func_start_service()
{
    chkconfig mysqld on
    chkconfig --add nginx
    chkconfig nginx on
    chkconfig php-fpm on

    service mysqld restart
    service php-fpm restart
    service nginx restart
    
}
function func_remove_service()
{
    chkconfig nginx off
    chkconfig php-fpm off
    chkconfig mysqld off

    service nginx stop
    service php-fpm stop
    service mysqld stop

    yum remove php-* mysql-server -y
    rm /etc/init.d/nginx -f
    rm /etc/nginx -fr
}
case "$1" in
    install)
        func_install_php_mysql
        func_install_nginx
        func_install_conf
        func_start_service
        ;;
    uninstall)
        func_remove_service
        ;;
    *)
        echo "$0 install | uninstall"
        exit
        ;;
esac
