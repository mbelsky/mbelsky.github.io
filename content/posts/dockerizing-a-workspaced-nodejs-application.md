---
title: "Dockerizing a Workspaced Node.js Application"
date: 2020-11-09T18:54:21+03:00
description: "Recipe to efficiently dockerize yarn workspaced app"
draft: false
tags: ["docker", "node.js", "yarn"]
---

Re-usage of build cache is one of the most important things in Docker images creating.

To efficiently dockerize an app you need to split source code copying and dependencies installation in a few steps:

1. Copy dependencies files.
1. Install dependencies.
1. Copy source code.

For a node.js application these steps look like:

```docker
COPY package.json yarn.lock ./

RUN yarn install

COPY . .
```

However, this solution does not work with yarn workspaced application because the root `package.json` and `yarn.lock` are not enough to install whole project dependencies.

When I faced this task the first time I thought: what if I find all nested `package.json` files and copy them to a `src` directory:

```docker
COPY src/**/package.json src/
```

`src/**/package.json` pattern matches all `package.json`'s that I need. But [`COPY`](https://docs.docker.com/engine/reference/builder/#copy) works as not I expected. And instead of the expected directories structure I've got a single file under the `src`.

<details>
<summary>Expand to see trees examples</summary>

```sh
# The original project's tree
app
├── package.json
├── src
│   ├── backend
│   │   ├── backend.js
│   │   └── package.json
│   ├── notifier
│   │   ├── notifier.js
│   │   └── package.json
│   └── scraper
│       ├── package.json
│       └── scraper.js
└── yarn.lock

# The expected tree
app
├── package.json
├── src
│   ├── backend
│   │   └── package.json
│   ├── notifier
│   │   └── package.json
│   └── scraper
│       └── package.json
└── yarn.lock

# The result tree
app
├── package.json
├── src
│   └── package.json
└── yarn.lock
```

</details>

For a second I thought I could replace the single pattern line with a `COPY` operation for every workspace. But I wanted to have a scalable solution, a solution without duplication.

## Shell solution

I've googled some alternative [solutions](https://stackoverflow.com/a/50010093/1088836). Commonly they suggest wrapping `docker build` with a script that creates a `tmp` folder, build the expected `package.json`'s tree there and `COPY` the folder in the image.

And the "shell solution" is much better than the previous "copy-paste" solution. But it did not make me feel pleased.

## Multi-stage builds solution

At some point, I thought of [multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/). I used it in another project to build a tiny production image. "What if I will prepare the tree on a first stage and copy it on a second stage?"

In addition to the root `package.json` and `yarn.lock` files I copied the `src` directory and removed all not `package.json` files:

```docker
COPY package.json yarn.lock ./
COPY src src

# Remove not "package.json" files
RUN find src \! -name "package.json" \
  -mindepth 2 \
  -maxdepth 2 \
  -print \
  | xargs rm -rf
```

On a second stage I copied the tree and installed dependencies:

```docker
COPY --from=0 /app .

RUN yarn install --frozen-lockfile --production=true
```

Under the hood `yarn workspaces` use symlinks. So it's important to create them after copying `src` directory:

```docker
COPY . .

# Restore workspaces symlinks
RUN yarn install --frozen-lockfile --production=true
```

## The final solution Dockerfile

```docker
FROM node:14.15.0-alpine3.10

WORKDIR /app
COPY package.json yarn.lock ./
COPY src src

# Remove not "package.json" files
RUN find src \! -name "package.json" -mindepth 2 -maxdepth 2 -print | xargs rm -rf

FROM node:14.15.0-alpine3.10

ENV NODE_ENV production

WORKDIR /app
COPY --from=0 /app .

RUN yarn install --frozen-lockfile --production=true

COPY . .

# Restore workspaces symlinks
RUN yarn install --frozen-lockfile --production=true

CMD ["yarn", "start"]
```

<!-- Join the discussion if you have any comments or suggestions -->
