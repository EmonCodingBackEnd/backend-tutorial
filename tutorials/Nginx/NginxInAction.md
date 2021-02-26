# Nginx实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、常规配置

## 1.1、 Nginx配置WebSocket

```nginx
location / {
    proxy_pass http://IP:Port;
    proxy_read_timeout 600s;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}
```



## 1.2、参考实现

```nginx
server {
  listen 8808;
  server_name 192.168.1.66;
  access_log  logs/scrm.access.log  main;

  location ^~ /h5/ {
      rewrite ^/(.*)$  /index.html last;
  }

  location / {
    #root html/dist;
    root /home/saas/huiba/scrm/huiba-scrm-h5/webroot/h5;
    index index.html index.htm;
  }

  location ^~ /api/ {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto  $scheme;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_pass http://192.168.1.66:28781;
  }

  location ^~ /mgr/ {
      #rewrite ^/(.*)$  /index.html last;
      root /home/saas/huiba/scrm/huiba-scrm-web/webroot/;
      index index.html index.htm;
      add_header Access-Control-Allow-Origin *;
  }
}
```



```nginx
server {
    listen       80;
    listen       443 ssl;
    server_name  edeninterface.ishanshan.com;
    ssl_certificate      /usr/local/openresty/nginx/conf/https/_.ishanshan.com_bundle.crt;
    ssl_certificate_key  /usr/local/openresty/nginx/conf/https/_.ishanshan.com.key;
    ssl_session_cache    shared:SSL:1m;
    ssl_session_timeout  5m;
    ssl_ciphers  HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers  on;
    ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    #charset koi8-r;

    #access_log  logs/host.access.log  main;

    location / {
        rewrite ^/website/introduction$  /eden-server/website/introduction last;
    }

    location ^~ /eden-server/website/introduction {
        #location ^~ /website/introduction {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        #proxy_set_header x-rule "offline";
        proxy_pass http://edeninterface;
        proxy_read_timeout 600s;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   html;
    }
    error_page  404              /404.html;

    location = /404.html {
        root   html;
    }

}
```



```nginx
server {
    listen 80;
    autoindex off;
    server_name interface.tamizoo.cn;
    # HTTPS ?.疆寮濮
    #if ($server_port = 80) {
    #   rewrite ^http://$host https://$host permanent;
    #   rewrite ^(.*)$ https://$host$1 permanent;
    #}
    listen 443;
    ssl on;
    ssl_certificate      cert/interface.tamizoo.cn/214688233200754.pem;
    ssl_certificate_key  cert/interface.tamizoo.cn/214688233200754.key;
    ssl_session_timeout 5m;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    # HTTPS ?.疆缁..
    access_log /usr/local/nginx/logs/access.log combined;
    index index.html index.htm index.jsp index.php;
    #error_page 404 /404.html;
    if ( $query_string ~* ".*[\;'\<\>].*" ){
        return 404;
    }

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_read_timeout 600s;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

