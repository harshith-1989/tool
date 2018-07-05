#!/usr/bin/env bash


#setup_web_directory_listing -w <root folder name> -sudo_passwd <password>
usage="$(basename "$0") -w <web root> -p <sudo password>"

while getopts w:p:h option
do
case "${option}"
in
h)
    echo -e "Usage: $usage"
    exit 0
    ;;
w) web_root=${OPTARG}
    ;;
p) sudo_passwd=${OPTARG}
    ;;
*)
    handle_error "Invalid Argument!!\nUsage: $usage"
    ;;
esac
done

export root_folder="${HOME}/${web_root}"
export username=$( whoami )
export sudo_passwd

mkdir -p "$root_folder"/Downloads

rm -rf /tmp/*

echo -e "<Directory \"$root_folder\">\n  AllowOverride All \nOptions Indexes MultiViews FollowSymLinks \nRequire all granted\n</Directory>" >> /tmp/$username.conf
echo "<!doctype html><html><head><title>Hello, World! | Foo</title></head><body><h1>Hello, World!</h1><p>Welcome to <strong>Foo</strong>.</p></body></html>" >> "$root_folder"/Downloads/index.html

# create a username.conf
echo "$sudo_passwd" | sudo -S cp -f /tmp/$username.conf /etc/apache2/users/
echo "$sudo_passwd" | sudo -S chmod 644 /etc/apache2/users/$username.conf
echo "$sudo_passwd" | sudo -S cp /etc/apache2/httpd.conf /etc/apache2/httpd.conf.bak
echo "$sudo_passwd" | sudo -S cp /etc/apache2/extra/httpd-userdir.conf /etc/apache2/extra/httpd-userdir.conf.bak

#iterate over these array items and uncomment them in httpd.conf
httpd_conf_array=( "LoadModule authz_host_module libexec/apache2/mod_authz_host.so" "LoadModule authz_core_module libexec/apache2/mod_authz_core.so" "LoadModule userdir_module libexec/apache2/mod_userdir.so" "LoadModule vhost_alias_module libexec/apache2/mod_vhost_alias.so" "Include /private/etc/apache2/extra/httpd-userdir.conf" "Include /private/etc/apache2/extra/httpd-vhosts.conf" )

for item in "${httpd_conf_array[@]}"
do
    echo "$sudo_passwd" | sudo -S sed -e s+\#"$item"+"$item"+g /etc/apache2/httpd.conf > /tmp/httpd.conf
    echo "$sudo_passwd" | sudo -S mv /tmp/httpd.conf /etc/apache2/httpd.conf
    echo "$sudo_passwd" | sudo -S rm -f /tmp/httpd.conf
done

#change the document root & directory value in the httpd.conf
document_root='DocumentRoot'
    echo "$sudo_passwd" | sudo -S sed -e s+"$document_root .*"+"$document_root $root_folder"+g /etc/apache2/httpd.conf > /tmp/httpd.conf
    echo "$sudo_passwd" | sudo -S mv /tmp/httpd.conf /etc/apache2/httpd.conf
    echo "$sudo_passwd" | sudo -S rm -f /tmp/httpd.conf

directory='Directory'
    echo "$sudo_passwd" | sudo -S sed -e s+"\<$directory .*\>"+"\<$directory $root_folder\>"+g /etc/apache2/httpd.conf > /tmp/httpd.conf
    echo "$sudo_passwd" | sudo -S mv /tmp/httpd.conf /etc/apache2/httpd.conf
    echo "$sudo_passwd" | sudo -S rm -f /tmp/httpd.conf

# uncomment the include & modify the web root
httpd_userdir_conf_item='Include /private/etc/apache2/users/'
    echo "$sudo_passwd" | sudo -S sed -e s+\#"$httpd_userdir_conf_item"+"$httpd_userdir_conf_item"+g /etc/apache2/extra/httpd-userdir.conf > /tmp/httpd-userdir.conf
    echo "$sudo_passwd" | sudo -S mv /tmp/httpd-userdir.conf /etc/apache2/extra/httpd-userdir.conf
    echo "$sudo_passwd" | sudo -S rm -f /tmp/httpd-userdir.conf

userdir_item='UserDir'
    echo "$sudo_passwd" | sudo -S sed -e s+"$userdir_item .*"+"$userdir_item $web_root"+ /etc/apache2/extra/httpd-userdir.conf > /tmp/httpd-userdir.conf
    echo "$sudo_passwd" | sudo -S mv /tmp/httpd-userdir.conf /etc/apache2/extra/httpd-userdir.conf
    echo "$sudo_passwd" | sudo -S rm -f /tmp/httpd-userdir.conf

# restart the apache
echo "$sudo_passwd" | sudo -S apachectl restart

rm -f $root_folder/index.html
rm -f $root_folder/Downloads/index.html