# WordPress local development with Docker

#### Version 0.5.1

[![dockeri.co](https://dockeri.co/image/ideasonpurpose/wordpress)](https://hub.docker.com/r/ideasonpurpose/wordpress)<br>
[![Push to Docker Hub](https://github.com/ideasonpurpose/docker-wordpress-dev/workflows/Push%20to%20Docker%20Hub/badge.svg)](https://github.com/ideasonpurpose/docker-wordpress-dev)

## About This Project

This project provides local development environments for developing WordPress websites. This includes pre-configured Docker-based MySQL and PHP servers, our [Docker-Build toolchain][docker-build] and a number of helper scripts.

## Getting Started

To update an existing project or start a new one, run the following commands in your working directory.

##### macOS, Linux & Windows PowerShell

```
docker run --rm -it -v ${PWD}:/usr/src/site ideasonpurpose/wordpress:0.5.1 init
npm run bootstrap
```

##### Windows Command Prompt

```
docker run --rm -it -v %cd%:/usr/src/site ideasonpurpose/wordpress:0.5.1 init
npm run bootstrap
```

The `init` command copies all the necessary tooling files into place and sets up the default theme directory structure. Then``npm run bootstrap` readies the environment ready by installing npm and composer dependencies and reloading the database.

> _**Question:** Should the bootstrap script also call `npm run start` to kick off the devserver? Or print a message with instructions pointing to `npm run start`? Or do nothing?_

### Setup and Prerequisites

[**Docker**](https://www.docker.com/products/docker-desktop) and **npm** ([node.js](https://nodejs.org/en/download/)) should be installed. The development server runs from Docker images and all workflow commands are called from npm scripts.

### New Projects

In an empty directory, running `init` will prompt for the new project's name and description, then build out a complete environment with a basic theme skeleton.

### Existing Projects

For existing projects, running `init` reads the project's name and description from **package.json**, updates build tools and script commands to the latest versions and syncs in any missing theme files. The project should be a working Git checkout so any undesirable changes can be easily reverted.

Before calling `npm run start`, copy a database snapshot into the top-level **\_db** directory, copy any required plugins to **Plugins** and mirror media files to **Uploads**.

#### These files will be updated:

- Docker-compose files will be updated to the latest versions.
- Default package.json scripts will be merged onto existing scripts.
- DevDependencies, Scripts and Prettier properties will be copied onto existing package.json values.
- Default composer.json packages and metadata will be copied onto existing composer.json values.
- Update .gitignore from [gist](https://gist.github.com/joemaller/4f7518e0d04a82a3ca16)
  .gitignore
- Basic theme folder-structure will be non-destructively refreshed with missing folders added.
- Missing ideasonpurpose.config.js files will be created.
- Permissions will be reset for the theme directory and known tooling files.

Plugins and Uploads folders should not be committed to Git, but should be mirrored from production sites so the local environment works as expected.

### Databases

Copy your MySQL database dumpfiles into the top-level **\_db** directory before calling `npm run start`. The [MySQL Docker image](https://hub.docker.com/_/mysql#initializing-a-fresh-instance) will load all `*.sql` files from that directory in alphabetical order. Later files will overwrite earlier ones.

## Workflow & Commands

### Basic development commands

- **`npm run start`**  
   Spins up a database and php server, then serves all content through the devServer proxy at [http://localhost:8080]. Files in the project directory will be watched for changes and trigger reloads when saved. Type **control-c** to stop the local server.

- **`npm version [major|minor|patch]`**
  Increments the version then uses [version-everything][] to update project files before calling `npm run build` which generates a production build and compresses all theme files into a versioned, ready-to-deploy zip archive.

### Additional Commands and helpers

- **`bootstrap`**<br>
  A helper script for starting projects. This will install npm and composer depenencies, reload the MySQL database, activate the development theme and sort the package.json file.
- **`build`** - Generate a production-ready build in a zip archive. Ready-to-deploy.
- **`composer`**<br>
  Runs `composer install` from Docker.
  - **`composer:install`** - Installs packages from the composer.lock file
  - **`composer:require`** - Add new packages and update composer.json
  - **`composer:update`** - Updates composer dependencies to their newest allowable version and rewrites the **composer.lock** file.
- **`mysql`**<br>
  Opens a mysql shell to the development WordPress database
  - **`mysql:dump`**, **`mysqldump`** - Writes a compressed, timestamped database snapshot into the **\_db** directory
  - **`mysql:reload`** - Drops, then reloads the database from the most recent dumpfile in **\_db** then attempts to activate the development theme.
- **`phpmyadmin`** - Starts a phpMyAdmin server at [localhost:8002](http://localhost:8002)
- **`logs:wordpress`** - Stream the WordPress debug.log
- **`wp-cli`** - Runs [wp-cli](https://wp-cli.org/vc) commands. The default command re-activates the development theme.

#### Accessing running containers

To open a shell on _any_ running Docker container, run `docker ps` to retrieve continer IDs or Names, then run `docker exec -it <name or ID> bash`. Some containers may use `sh` instead of bash. To open a shell on the running WordPress instance, run `docker-compose exec wordpress bash`.

#### Other composer commands

The [Composer][] image can also run other, more specific commands directly from `docker-compose`:

```sh
docker-compose -f docker-compose.yml -f docker-compose-util.yml run --rm  composer update
docker-compose -f docker-compose.yml -f docker-compose-util.yml run --rm  composer require monolog/monolog

# Open a shell in the composer image

docker-compose -f docker-compose.yml -f docker-compose-util.yml run --rm  composer bash
```

### Alternate DevServer Ports

Webpack devserver runs on port `8080` by default. Multiple projects can be run simultaneously by using `npm config` to assign different ports the the project's **package.json** `name`. For example, three projects named `csr-site`, `pro-bono` and `ar-project` could be run simultaneously on custom ports, after running these commands:

```sh
npm config set csr-site:port 8080
npm config set pro-bono:port 8081
npm config set ar-project:port 8082
```

### `phpinfo()`

A PHP Info page is available at [`localhost:8080/info.php`](http://localhost:8080/info.php).

### wp-cli

The default command replaces the `wp` prefix, so alternate commands would look like this:

- `npm run wp-cli transient delete --all`
- `npm run wp-cli user list`

[wp-cli Command Reference](https://developer.wordpress.org/cli/commands/)

## Local Development

To iterate on this project locally, build the image using the same name as the Docker Hub remote. Docker will use the local copy. Specify `dev` if you're using using versions.

```sh
$ docker build . --tag ideasonpurpose/wordpress:dev
```

### Dockerfile

This project's Dockerfile is based on the official WordPress image. We add [Xdebug](https://xdebug.org/), the [ImageMagick](http://www.imagemagick.org/) PHP extension and enable all PHP debug settings.

## Docker maintenance

While not specific to this project, here are a few useful docker commands for keeping Docker running.

- `docker-compose down` tears down the containers
- `docker system prune` Clean up unused containers and images
- `docker system prune -a` Clean everything, will need to download stuff again
- `docker ps` List running containers
- `docker exec -it <container> bash` Open a shell on a running container

<!--

#### _Edited to here..._

## Goals

### Local development and maintenance

All sorts of WordPress-Docker projects show how to set up a fresh environment for developing a new site. But these rarely cover using Docker to maintain an existing site.

_Existing site maintenance is the main goal of this project._

Starting a vanilla WordPress project on Docker is not difficult, but apparently setting up a populated local development environment is. This project aims to change that.

Our primary use case is to enable fast iteration for existing sites. With a cloned codebase, a database dump and cached Docker images, a cross-platform development environment can be spun up in a few seconds.

## Getting Started

The **package.json** file is the Single Source of Truth for environment and configuration. Settings such as theme-name and devServer port are passed directly from `npm_package_*` environment variables.

### Existing Projects

Existing WordPress sites have three highly portable components contained in `wp-content`:

1. **A theme directory**
   All files related to appearance and non-plugin functionality live here.
2. **A MySQL dumpfile**
   All the user-authored content and settings from the site
3. **The uploads directory**
   A copy of all the user-uploaded imagery used on the site.
4. **The Plugins directory**
   A blob of plugin files. Most of these can be pulled from [wordpress.org/plugins](https://wordpress.org/plugins/) but it's often faster to copy the whole `wp-content/plugins` directory to dev sites.

Docker Desktop should be installed. The tools should work equally well on any platform that can run Docker, we're using it in production on macOS and Windows, including and WSL 2.

### Project Directory Structure

Non-wordpress project files should be parallel to the wp-content directory. Something like this:

```
Project Root
├─┬ _db
│ └── project.sql
├─┬ wp-content
│ ├─┬ themes
│ │ └── project-theme-directory
│ ├─┬ plugins
│ │ └── ...
│ └─┬ uploads
│   └── ...
├── composer.json
├── docker-compose-util.yml
├── docker-compose.yml
└── package.json
```

## What's in here

## Included Tools, Commands, etc.

_TODO: Does this still work?_

Calling `docker-compose up -d` will run everything. To discover ports afterwards, run `docker-compose ps`. To clean up and deactivate any active containers, run `docker-compose down`.

### Xdebug Profiles & The WebGrind Viewer

To profile a request with Xdebug, add `?XDEBUG_PROFILE=1` to the url.

[WebGrind](https://github.com/jokkedk/webgrind/) is included in the utility docker compose file to help view results and identify slow code. Call `npm run webgrind` then visit [localhost:9001](http://localhost:9001) and select a profile from the top menu.

Profiler files will be in a top-level directory named `_profiler`. These can be viewed with a tool like KCacheGrind, QCacheGrind, WinCacheGrind

#### Reading Call Graphs

Every profiled run can also be viewed as a call graph. These graphs are [documented in the gprof2dot project](https://github.com/jrfonseca/gprof2dot#output):

```
+------------------------------+
|        function name         |
| total time % ( self time % ) |
|         total calls          |
+------------------------------+
```

> where:
>
> - **_total time %_** is the percentage of the running time spent in this function and all its children;
> - **_self time %_** is the percentage of the running time spent in this function alone;
> - **_total calls_** is the total number of times this function was called (including recursive calls).

-->

[basic-wordpress-vagrant]: https://github.com/ideasonpurpose/basic-wordpress-vagrant
[basic-wordpress-box]: https://github.com/ideasonpurpose/basic-wordpress-box
[env-file]: https://docs.docker.com/compose/compose-file/#env_file
[composer]: https://getcomposer.org/
[docker-build]: https://github.com/ideasonpurpose/docker-build
[phpmyadmin]: https://www.phpmyadmin.net/
