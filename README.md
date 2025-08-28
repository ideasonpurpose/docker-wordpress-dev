# WordPress local development with Docker

<h4> 
Version 1.7.8
<!-- WPVERSION -->- WordPress 6.8.2
</h4>

<!-- [![dockeri.co](https://dockeri.co/image/ideasonpurpose/wordpress)](https://hub.docker.com/r/ideasonpurpose/wordpress)<br> -->

[![Docker Pulls](https://img.shields.io/docker/pulls/ideasonpurpose/wordpress?logo=docker&logoColor=white)](https://hub.docker.com/r/ideasonpurpose/wordpress)
[![Push to DockerHub](https://img.shields.io/github/actions/workflow/status/ideasonpurpose/docker-wordpress-dev/push-to-dockerhub.yml?logo=github&logoColor=white&label=Push%20to%20DockerHub)](https://github.com/ideasonpurpose/docker-wordpress-dev/actions/workflows/push-to-dockerhub.yml)

## About This Project

This project provides local development environments for fast iteration of existing WordPress websites. This includes pre-configured Docker-based MySQL and PHP servers, our [Docker-Build toolchain][docker-build], [Xdebug](https://xdebug.org/), [ImageMagick](http://www.imagemagick.org/) and a number of helper scripts.

The project builds on the official WordPress docker image, currently **[v6.8.2](https://hub.docker.com/_/wordpress)**

## Getting Started

To update an existing project or start a new one, run the following commands in your working directory.

##### macOS, Linux & Windows PowerShell

```
docker run --rm -it -v ${PWD}:/usr/src/site ideasonpurpose/wordpress:6.8.2 init
```

Followed by:

```
npm run bootstrap
```

_NOTE: If **~/.composer** doesn't exist, mounting the Docker volume will create the directory with root ownership, likely causing the Composer task to fail. Either create this directory before running `npm run bootstrap` or reset it's ownership with `sudo chown -R $UID:$GID .composer` and then run `bootstrap` again. See [#21](https://github.com/ideasonpurpose/docker-wordpress-dev/issues/21)_

##### Windows Command Prompt

```
docker run --rm -it -v %cd%:/usr/src/site ideasonpurpose/wordpress:6.8.2 init
```

- `init` command copies all the necessary tooling files into place and sets up the default theme directory structure.
- `npm run bootstrap` prepares the environment by installing npm and composer dependencies and reloading the database.

### Setup and Prerequisites

[**Docker**](https://www.docker.com/products/docker-desktop) and **npm** ([node.js](https://nodejs.org/en/download/)) should be installed. The development server runs from Docker images and all workflow commands are called from npm scripts.

### New Projects

In an empty directory, running `init` will prompt for the new project's name and description, then build out a complete environment with a basic theme skeleton.

### Existing Projects

Recently updated project can run `npm run project:refresh` to update tooling to the latest release.

Older projects should run `init` manually to update. Projects should be in a clean Git working tree so any undesirable changes can be easily reverted.

#### These files will be updated:

- Docker-compose files will be updated to the latest versions.
- Default package.json scripts will be merged onto existing scripts.
- DevDependencies, Scripts and Prettier properties will be copied onto existing package.json values.
- Default composer.json packages and metadata will be copied onto existing composer.json values.
- Update .gitignore from [gist](https://gist.github.com/joemaller/4f7518e0d04a82a3ca16)
- Basic theme folder-structure will be non-destructively refreshed with missing folders added.
- Missing ideasonpurpose.config.js files will be created.
- Permissions will be reset for the theme directory and known tooling files.

Before calling `npm run start`, copy a database snapshot into the top-level **\_db** directory, add any required plugins to **Plugins** and mirror media files to **Uploads**.

Plugins and Uploads folders should not be committed to Git, but should be mirrored from production sites so the local environment works as expected.

After configuring your SSH key path in **.env**, the database, plugins and uploads be can be synced down from a remote server with the `npm run pull` command. The **.env.sample** file documents the required credentials.

### Databases

All `*.sql` files from the top-level **\_db** directory will be in alphabetical order. Later files will overwrite earlier ones.

## Workflow & Commands

### Basic development commands

- **`npm run start`**  
   Spins up a database and php server, then serves all content through the devServer proxy at [http://localhost:8080](http://localhost:8080). Files in the project directory will be watched for changes and trigger reloads when saved. Type **control-c** to stop the local server. Change the default port with `--port=8080`

- **`npm version [major|minor|patch]`**
  Increments the version then uses [version-everything][] to update project files before calling `npm run build` which generates a production build and compresses all theme files into a versioned, ready-to-deploy zip archive.

### Additional Commands and helpers

- **`bootstrap`**<br>
  A helper script for starting projects. This will install npm and composer dependencies, reload the MySQL database, activate the development theme and sort the package.json file.
- **`build`** - Generate a production-ready build in a zip archive. Ready-to-deploy.
- **`composer`**<br>
  Runs `composer install` from Docker.
  - **`composer:install`** - Installs packages from the composer.lock file
  - **`composer:require`** - Add new packages and update composer.json
  - **`composer:update`** - Updates composer dependencies to their newest allowable version and rewrites the **composer.lock** file.
    Opens a mysql shell to the development WordPress database
- **`db:admin`** - Starts a phpMyAdmin server at [localhost:8002](http://localhost:8002)
- **`db:dump`** - Writes a compressed, timestamped database snapshot into the **\_db** directory
- **`db:pull`** - Alias for `pull:db`
- **`db:reload`** - Drops then reloads the database from the most recent dumpfile in **\_db**, then attempts to activate the development theme
- **`db:shell`** - Opens a shell to the development WordPress database
- **`dev`** - Alias for `start`
- **`mariadb`**, **`mysql`** - Aliases for `db:admin`
- **`mariadb-dump`**, **`db:dump`**, **`mysql:dump`**, **`mysqldump`** - Aliases for `db:dump`
- **`mariadb:reload`**, **`mysql:reload`** - Aliases for `db:reload`
- **`phpmyadmin`** - Alias for `db:admin`
- **`project:refresh`** - Update the project with the latest tooling.
- **`pull`**<br>
  Syncs data from a remote server to the local development environment. The bare command will run these sub-commands:
  - **`pull:db`** - Syncs down the most recent mySQL dumpfile, backs up the current dev DB then reloads the DB
  - **`pull:plugins`** - Syncs down **wp-content/plugins** from the remote
  - **`pull:uploads <$YEAR>`** - Syncs down the current year's **wp-content/uploads/$YEAR** from the remote. Sync specific years with the optional year argument.
  - **`pull:uploads-all`** - Syncs down the entire **wp-content/uploads** directory from the remote
- **`logs:wordpress`** - Stream the WordPress debug.log
- **`wp-cli`** - Runs [wp-cli](https://wp-cli.org/vc) commands. The default command re-activates the development theme.

#### Permissions Repair on macOS

On macOS hosts, modifying permissions _inside_ a mounted Docker volume will add extended attributes to the shared files on the host instead of modifying their actual mode or ownership. To see these values in the terminal, run `ls -la@` or `xattr -l <file>`. Extended attribute values are prefixed with `com.docker.grpcfuse` regardless of whether Docker is using gRPC FUSE or VirtioFS ([they're both FUSE](https://www.docker.com/blog/deep-dive-into-new-docker-desktop-filesharing-implementation/)).

### Pulling Data from Remote Servers

The `npm run pull` command brings together several sub-commands to sync remote data to the local development environment. Each command can also be called individually. Connection info must be configured in a **.env** file. Values are documented in the **.env.sample** file.

Private SSH keys are passed to the image as [Docker Secrets][docker-secrets], point `$SSH_KEY_PATH` to a local private key in **.env**.

Pulling uploads, plugins and database dumps is currently supported on WP Engine and Kinsta\*.

Connections must be configured on a per-machine basis using a `.env` file in the project root. For new projects, rename the `.env.example` to **.env** and update the settings.

The important properties are:

- **`SSH_KEY_PATH`**<br>
  Local path to your private key. If you uploaded a `id_rsa_wpengine.pub` key to your WP Engine account,
  point this to the pair's matching private key: `~/.ssh/id_rsa_wpengine`

- **`SSH_LOGIN`**<br>
  This is simply the SSH connection string from WP Engine backend, something like `iop001@iop001.ssh.wpengine.net`
  where the elements are `${SSH_USER}@${SSH_HOST}`. Each item can also be entered individually, individual entries
  take precedence over components extracted from SSH_CONNECT_STRING.

- **`SSH_USER`**<br>
  The user account which connects to the server.

- **`SSH_HOST`**<br>
  The server address to connect to.

- **`SSH_WP_CONTENT_DIR`**<br> (default: sites/${SSH_USER}/wp-content)
  The path to the wordpress wp-content folder. Most likely matches the `WP_CONTENT_DIR` WordPress constant.
  Does not include a trailing slash. Can relative to the SSH user home folder or an absolute path.

Both `$SSH_LOGIN` and `$SSH_HOST` can be extracted from `$SSH_LOGIN`. Specifying either will override the value in `$SSH_LOGIN`.

#### Syncing Databases from Kinsta

Unlike WP Engine, Kinsta does not store regular database snapshots in a site's **wp-content** directory, but they do allow cron. Set up a basic crontab task to regularly backup the database so pull scripts will work correctly. Here's an example which backs up hourly at 37 minutes after the hour:

```cron
# dump db hourly for dev mirrors
37      *       *       *       *       mysqldump --default-character-set=utf8mb4 -udb_user -pdb_password db_name > ~/public/wp-content/mysql.sql
```

Neither Kinsta's nor WP Engine's servers will not fulfil requests for \*.sql files, and the `db_user`. `db_password` and `db_name` values are stored already stored in plaintext in **wp-config.php** so this isn't a security risk.

### Debugging

`WP_DEBUG` is enabled by default, and can be toggled by setting the `WORDPRESS_DEBUG` variable in the **.env** config file.

### Updating WordPress

The base image provides a specific version of WordPress, but once running that version can be upgraded using the wp-admin dashboard, just like any other site.

wp-cli can also be used to update to [pre-release](https://wordpress.org/download/releases/#betas) version of WordPress. An example command looks like this:

```sh
npm run wp-cli wp core update https://wordpress.org/wordpress-6.5-RC3.zip
```

Versions can be rolled back by removing the docker `*_wp` volume.

#### Bumping Image Versions

The `npm run bump` script will query the WordPress releases API and DockerHub, then update the docker image and readme to the latest WordPress image.

To update to a pre-release image, enter a valid DockerHub tag into the wp-version.json file.

### Plugin Development

Projects often rely on plugins which are developed in parallel. A number of placeholder `IOP_DEV_PLUGIN_#` environment variables are provided which can be used to directly mount plugins into the WordPress environment. These enable better version control and dependency management since the nested and .gitignored **wp-content/plugins** directory often conflicts with a parent theme.

To add a development plugin to the WordPress environment, point the plugin's local relative path to an absolute path inside the container. Here's how we would make an **example-plugin** project being developed in a sibling directory available to the current WordPress development environment:

```
   IOP_DEV_PLUGIN_1="../example-plugin:/var/www/html/wp-content/plugins/example-plugin"
   IOP_DEV_PLUGIN_2=
   IOP_DEV_PLUGIN_3=
```

#### Accessing running containers

To open a shell on _any_ running Docker container, run `docker ps` to retrieve container IDs or Names, then run `docker exec -it <name or ID> bash`. Some containers may use `sh` instead of bash. To open a shell on the running WordPress instance, run `docker-compose exec wordpress bash`.

#### Other composer commands

The [Composer][] image can also run other, more specific commands directly from `docker-compose`:

```sh
docker-compose run --rm  composer update
docker-compose run --rm  composer require monolog/monolog

# Open a shell in the composer image

docker-compose run --rm  composer bash
```

### Serving on Alternate Ports

All services which provide a server can have their default ports customized with the `--port=` flag. This allows for multiple projects to be run simultaneously on the same computer.

```sh
# site one
npm run start --port=8080

# site two
npm run start --port=8081
```

#### Default ports

- webpack devserver: `8080`
- phpMyAdmin: `8002`
- WebGrind: `9004`

### `phpinfo()`

A PHP Info page is available at [`localhost:8080/info.php`](http://localhost:8080/info.php).

## Debugging & Profiling

To profile a request with [XDebug][xdebug] and [WebGrind][], add `?XDEBUG_PROFILE=1` to any request. A **cachegrind.out.nn** file will be created in webpack/xdebug. Running `npm run webgrind` will launch a webgrind server for viewing those files. The default address is <http://localhost:9004>, or change ports with `npm run webgrind --port=9123`.

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

### wp-cli

The default command replaces the `wp` prefix, so alternate commands would look like this:

- `npm run wp-cli transient delete --all`
- `npm run wp-cli user list`

[wp-cli Command Reference](https://developer.wordpress.org/cli/commands/)

## Local Development

To iterate on this project locally, build the image using the same name as the Docker Hub remote. Docker will use the local copy. Specify `dev` if you're using using versions.

```sh
docker build . --tag ideasonpurpose/wordpress:dev
```

### Shell Scripts

All shell scripts in **bin** have been checked with [ShellCheck](https://www.shellcheck.net/) and formatted with [shfmt](https://github.com/mvdan/sh) with command: `npm run shfmt`

## Docker maintenance

While not specific to this project, here are a few useful docker commands for keeping Docker running.

- `docker-compose down` tears down the containers
- `docker system prune` Clean up unused containers and images
- `docker system prune -a` Clean everything, will need to download stuff again
- `docker ps` List running containers
- `docker exec -it <container> bash` Open a shell on a running container

### Additional Notes

The **docker-entrypoint.sh** script in the base WordPress docker image checks for a WordPress installation by checking for **index.php** and **wp-includes/version.php**.

<!--

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
├── docker-compose.yml
└── package.json
```

## What's in here

## Included Tools, Commands, etc.


-->

<!-- START IOP CREDIT BLURB -->

## &nbsp;

#### Brought to you by IOP

<a href="https://www.ideasonpurpose.com"><img src="https://raw.githubusercontent.com/ideasonpurpose/ideasonpurpose/master/iop-logo-white-on-black-88px.png" height="44" align="top" alt="IOP Logo"></a><img src="https://raw.githubusercontent.com/ideasonpurpose/ideasonpurpose/master/spacer.png" align="middle" width="4" height="54"> This project is actively developed and used in production at <a href="https://www.ideasonpurpose.com">Ideas On Purpose</a>.

<!-- END IOP CREDIT BLURB -->

[basic-wordpress-vagrant]: https://github.com/ideasonpurpose/basic-wordpress-vagrant
[basic-wordpress-box]: https://github.com/ideasonpurpose/basic-wordpress-box
[env-file]: https://docs.docker.com/compose/compose-file/#env_file
[version-everything]: https://github.com/joemaller/version-everything
[composer]: https://getcomposer.org/
[docker-build]: https://github.com/ideasonpurpose/docker-build
[phpmyadmin]: https://www.phpmyadmin.net/
[docker-secrets]: https://docs.docker.com/compose/compose-file/compose-file-v3/#secrets
[xdebug]: https://xdebug.org/
[webgrind]: https://github.com/jokkedk/webgrind
