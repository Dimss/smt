#!/usr/bin/env bash
sudo apt-get -y update
sudo apt-get -y install nginx locales
sudo unlink /etc/nginx/sites-enabled/default
sudo locale-gen en_US.UTF-8
sudo cat << EOF > /etc/nginx/sites-enabled/web-app
server {
    listen 80;
    charset utf-8;
    location / {
        proxy_set_header HOST $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        set $backend_upstream "http://${service_name}.${sd_ns_name}:8080";
        proxy_pass $backend_upstream;
        proxy_buffer_size          128k;
        proxy_buffers              4 256k;
        proxy_busy_buffers_size    256k;
    }
}
EOF
sudo systemctl start nginx
sudo systemctl enable nginx