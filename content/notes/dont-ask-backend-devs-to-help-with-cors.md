---
title: "Don't Ask Backend Devs to Help With Cors"
date: 2021-05-28T17:29:04+03:00
description: "An alternative solution how to fix the CORS errors with proxy"
draft: false
---

## Webpack proxy

This small config helps setup a proxy for projects bundled with Webpack:

```javascript
{
  devServer: {
    proxy: {
      '/api': {
        target: 'https://www.mbelsky.com',
        changeOrigin: true,
        cookieDomainRewrite: 'localhost',
      }
    }
  }
}
```

## Nginx proxy

This config works for apps served by Nginx:

```cfg
http {
  server {
    # …

    server_name localhost;

    location /api/ {
      proxy_cookie_domain www.mbelsky.com $server_name;
      proxy_http_version 1.1;
      proxy_pass https://www.mbelsky.com;
      proxy_ssl_server_name on;
    }

    location / {
      # serve frontend app's static
    }
  }
}
```

For other cases setup Nginx proxy on another port, hide the original response header with [`proxy_hide_header`](https://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_hide_header) and set the `Access-Control-Allow-Origin` header's value with [`add_header`](http://nginx.org/en/docs/http/ngx_http_headers_module.html#add_header):

```cfg
location /api/ {
  # …
  proxy_hide_header Access-Control-Allow-Origin;
  add_header Access-Control-Allow-Origin * always;
}
```
