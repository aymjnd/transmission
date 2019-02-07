Transmission-installer
============

AutoInstall Script for Linux Server

### Install
```bash
$ wget https://raw.githubusercontent.com/aymjnd/transmission/master/itransmission.sh
$ chmod +x itransmission.sh
$ sudo ./itransmission.sh
```
### Notes
- SSL setup
```bash
$ cd /etc/nginx/sites-available
$ sudo nano transmission
$ sudo ln -s /etc/nginx/sites-available/transmission /etc/nginx/sites-enabled/transmission
$ sudo service nginx restart
```

- transmissin config
```config
#
# Transmission ssl redirect
# https:2443 to http:9091
#
server {
    listen 2443 ssl;
    server_name srv.example.com;
    ssl_certificate /etc/letsencrypt/live/srv.example.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/srv.example.comt/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
    access_log            /var/log/nginx/nginx-2443.log;
    location / {
      proxy_set_header        Host $host;
      proxy_set_header        X-Real-IP $remote_addr;
      proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header        X-Forwarded-Proto $scheme;

      # Fix the .It appears that your reverse proxy set up is broken" error.
      proxy_pass          http://localhost:9091;
      proxy_read_timeout  90;
      proxy_redirect      http://localhost:9091 https://srv.example.com:2443;
    }
}
```

