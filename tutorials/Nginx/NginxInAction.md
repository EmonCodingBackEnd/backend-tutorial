# Nginx学习

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、常规配置

## 1.1 Nginx配置WebSocket

```nginx
location / {
    proxy_pass http://IP:Port;
    proxy_read_timeout 600s;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}
```



