---
title: "Serve React applicaiton with Nginx in k8s"
date: 2021-02-28T16:26:02+03:00
draft: false
tags: ["react", "nginx", "k8s"]
---

A few things I've learned after deploying React application + nginx in Kubernetes.

## `nobody` user

To run a process as non-root you don't need create a user in your docker image. Just use the `nobody`:

```sh
docker run --user="nobody"
```

## nginx read-only container

To succesfully run a read only container with nginx don't forget to pass some volumes:

```sh
docker run --read-only --tmpfs "/var/cache/nginx" --tmpfs "/run" --rm nginx-react-app
```

In k8s add `volumes` and use them as the container's `volumeMounts`.

## nginx.conf

```nginx
events {}

http {
  server {
    # non-root user can't listen 80 port
    listen 8080;
    root /usr/share/nginx/html;

    location / {
      # tricky location here because the app works on example.com/PATH_TO_THE_APP/
      location ~ .*/(\w+\.\w+).js(.map)?$ {
        try_files $uri /$1.js$2;
      }

      try_files $uri /index.html;
    }
  }
}
```

## Dockerfile

```docker
FROM node:14.15 as build

WORKDIR /app

COPY ["package.json", "yarn.lock", "./"]

RUN yarn install --frozen-lockfile --production

COPY . .

# rm nginx.conf to make layers work
RUN rm nginx.conf \
  # The app should be bundled with webpack's HtmlWebpackPlugin.publicPath = 'auto'
  && yarn build

FROM nginx:1.19

COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/dist /usr/share/nginx/html

CMD ["nginx", "-g", "daemon off;"]
```
