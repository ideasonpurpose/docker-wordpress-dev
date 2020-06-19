# WordPress local development with Docker

#### Version 0.4.2

[![dockeri.co](https://dockeri.co/image/ideasonpurpose/wordpress)](https://hub.docker.com/r/ideasonpurpose/wordpress)<br>
[![Push to Docker Hub](https://github.com/ideasonpurpose/docker-wordpress-dev/workflows/Push%20to%20Docker%20Hub/badge.svg)](https://github.com/ideasonpurpose/docker-wordpress-dev)

This project replaces both the [basic-wordpress-vagrant][] and [basic-wordpress-box][] projects with a Docker-based workflow. It's much lighter than Vagrant, faster to spin up and inherently cross-platform.

## Workflow & Commands

### MySQL

For the most part, MySQL just works, but there are a few common tasks which come up; reloading the database from a dumpfile, dumping the database to a dumpfile and editing the database by either opening a shell or using [phpMyAdmin][]. These script commands are preconfigured to help with these tasks.

- **`npm run mysql:reload`**  
   Reloads `*.sql` files from the top-level **\_db** directory.

- **`npm run mysql:dump`**  
   Dumps a time-stamped, database snaphot to a zipped archive in the top-level **\_db** directory.

- **`npm run mysql`**  
   Opens a mysql shell in the database container.

- **`npm run phpmysqladmin`**  
   Starts up a phpMyAdmin server on port 8002.

### Composer

_blurb about composer tasks_

#### `npm run composer`

This runs the default `install` command, but also accepts other command arguments. For example `npm run composer dump-autoload` refreshes autoloader files.

#### `npm run composer:update`

Updates composer dependencies to newer version and rewrites the composer.lock file.

#### `npm run composer:require`

Use this command to add new packages to composer.json.

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

#### Manual Setup

Copy a mysql dumpfile to the top-level `_db` directory.
Copy the contents of **bolerplate-tooling** to the project root.
Merge the scripts and devDependencies sections of package.json onto your project's package.json file.

~~Call `npm run bootstrap`~~ _not working yet_

### Clean Start

For starting a new site, this will get a basic WordPress server running locally.

1. Create a project folder and `cd` into it: `mkdir my-wp-site && cd $_`
2. Run `docker run --rm -it -v ${PWD}:/usr/src/site ideasonpurpose/wordpress init`
3. Run `npm install`
4. Run `npm run composer`
5. Run `npm run start`

_Windows Note: Replace `${PWD}` with `%CD%` if using **cmd.exe**, `${PWD}` works in PowerShell_

Notes: Theme name will be set from this list, using the first found:

1. `NAME` environment variable
2. package.json `name` property (or `npm_package_name` env var)

If no name is found, the init script will prompt for a name.

### Project Directory Stucture

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
├── docker-compose-bootstrap.yml
├── docker-compose-util.yml
├── docker-compose.yml
└── package.json
```

<!--


```env
npm_package_name=project-name
```

Using npm's naming conventions means npm scripts work by default, the value should match the "name" property of package.json.

Get running in a few easy steps:

1. Copy your database dumpfile into a top-level `_db` directory, be sure the file has a `.sql` extension.

2. Clone your theme files into `./wp-content/themes/project-name`

3. Copy the Uploads and Plugins folders into wp-content

4. Copy the three docker-compose files to the project root

5. Finally, run the following:

```
npm run docker:start
// -- or
docker-compose run --rm -p 8080:8080 tools
```
-->

After calling `npm run start` Webpack DevServer will be serving the dev site from Docker at [localhost:8080](http://localhost:8080)

The first run make take some time as Docker downloads the necessary images. Subsequent runs take just a few seconds.

To stop the server type **control-c**. To stop docker (and clear ports), run `docker-compose down` which will teardown the virtual network and stop any active containers.

### Development Port

Webpack devserver runs on port `8080` by default. Multiple projects can be run simultaneously by assigning different ports using `npm config` with the **package.json** `name`. For example, three projects named `csr-site`, `pro-bono` and `ar-project` can be run simultaneously, on custom ports, after running these commands:

```sh
$ npm config set csr-site:port 8080
$ npm config set pro-bono:port 8081
$ npm config set ar-project:port 8082
```

<!--
We're also watching the [Docker app](https://github.com/docker/app) project and may be able to further simplifiy this by wrapping this project in an app description later on.
-->

## What's in here

### Dockerfile

The Dockerfile is based on the official WordPress image. We add [Xdebug](https://xdebug.org/), the [ImageMagick](http://www.imagemagick.org/) PHP extension and enable all PHP debug settings.

### Docker-compose

The `docker-compose.yml` files build on our Dockerfile, adding some utilities, diagnostic tools and helper apps.

### Package.json scripts (TODO)

Launching Docker with package.json scripts wraps up a lot of docker configuration and simplifies some especially verbose docker commands.

---

_below here needs work_

## Conventions

_TODO: switching to `.env` files as the source of truth_  
_TODO: start using dotenv library_

~~Whenever possible, named settings are derived from the `name` property in package.json. The docker-compose file contains sensible defaults, but taking advantage of the package.json scripts provides an even smoother developer experience.~~

### Database dumpfiles

Put MySQL dumpfiles in a top-level `_db` directory to populate the development database on `docker-compose up`. The [MySQL Docker image](https://hub.docker.com/_/mysql#initializing-a-fresh-instance) will load all `*.sql` files from that directory in alphabetical order. Later files will overwrite earlier ones.

#### Loading new dumpfiles (update the database)

-- tbd

## Included Tools, Commands, etc.

Calling `docker-compose up -d` will run everything. To discover ports afterwards, run `docker-compose ps`. To clean up and deactivate any active containers, run `docker-compose down`.

### `phpinfo()`

A PHP Info page is available at [`/info.php`](http://localhost:8080/info.php).

### MySQL

The MySQL command like client is available whenever the docker images are running. To access it, run this:

```sh
$ docker-compose exec db mysql
```

A few useful MySQL commands have been wrapped up in package.json scripts:

- `npm run mysql:dump`<br>
  Dumps the current MySQL database into a dated zip archive in **\_db**

- `npm run mysql:reload`<br>
  Drops the local database then reloads the last-found `*.sql` file in **\_db**

### phpMyAdmin

Run `npm run phpmyadmin` to launch a phpMyAdmin instance on port `8002`.

### wp-cli

WP-cli doesn't run as a sevice, but the imasge is pre-configured by the compose file to this specific WordPress instance. To access the command line, use `run` instead of `exec`, like this:

```sh
$ docker-compose run --rm wp-cli user list
```

### Composer

Similar to wp-cli, [Composer][] is available as a pre-configiured image.
Common commands like `install`, `update` and `require` are already configured as npm scripts:

```sh
$ npm run composer    # alias for composer:install
$ npm run composer:install
$ npm run composer:update
$ npm run composer:require -- monolog/monolog
```

More specific Composer commands can be run direclty from `docker-compose`:

```sh
$ docker-compose -f docker-compose.yml -f docker-compose-util.yml run --rm  composer  update
$ docker-compose -f docker-compose.yml -f docker-compose-util.yml run --rm  composer require monolog/monolog

# Open a shell in the composer image

docker-compose -f docker-compose.yml -f docker-compose-util.yml run --rm  composer bash

```

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

<!--
## Advantages

This project also bundles in our [docker-build toolchain][docker-build]. This has a number of advantages over including a gulpfile or webpack config in the project root. First and foremost, it encapsulates all the node dependencies, leaving only what's relevant to the projec tin niode_modules, instead of several thousand tool-related dependencies.
-->

## npm package.json scripts

This project bundles a lot of functionality and messy commands behind a small set of npm script commands.

### Primary Scripts

- build
- start
- version

### Task specific scripts

### The **start** pipeline

The start script is linked to several lifecycle scripts which do a lot more than just start the devserver. The `npm run start` lifecycle looks like this:

- `npm run start` Starts a development server and run build tools in docker
  - `poststart` is an alias for `npm run shutdown`
  - The `preshutdown` script runs first, creating a fresh dumpfile from the current MySQL DB
  - Then `shutdown` calls `npm run docker:stop` which just calls `docker-compose stop` to tear down the wordpress and db images.

## Windows Notes

VirtualBox and earlier versions of Docker [can not be installed simultaneously on Windows](https://technology.amis.nl/2017/07/17/virtualization-on-windows-10-with-virtual-box-hyper-v-and-docker-containers/).

> And the one finding that took longest to realize: Virtual Box will not work if Hyper-V is enabled. So the system at any one time can only run Virtual Box or Hyper-V (and Docker for Windows), not both. Switching Hyper-V support on and off is fairly easy, but it does require a reboot

## No more hostnames

When working with Vagrant, we used the vagrant hostmanager plugin to set up and point a project-name.test domain at our dev site. This was nice whjen working on one computer, but the reality bnow is that we're working on many all the time. Whatever the site is being developed on, it's likely being previewed on a handful of different desktop and mobile devices where that lovely development domain is irrelevant.

So, despite fantastic, cross-platform solutions like [Hostile](https://www.npmjs.com/package/hostile), we're dropping `*.test` development domains in favor of proxying everything through the Webpack DevServer.

## Theme Boilerplate Notes

> Todo: Temporary location, give this a better home.

base - tag styles in \_base.scss, \_reset.scss, anything else that basic. fonts would go here too
layouts - page specific files, there are NOT reusables
lib - external libraries
mixins
modules - reusables (blocks, components, headlines, buttons etc.)
variables - site settings (colors, breakpoints, grids settings, themes, etc.)
main.scss - only imports everything, nothing else should be here (edited)

## Notes

> todo: move these somewhere

- The wp-content/debug.log file should be writeable by the web user. If logs aren't being written, try `chmod a+w wp-content/debug.log`.

- All scripts are assumed to require jQuery and will include jQuery as a dependency. It's very difficult to get jQuery _out_ or WordPress, so instead of bundling in a second copy of the library, we just use what's there and assume it will already have been required by something else. (TODO: check this)
- To open a shell on the WordPress instance, run `docker-compose exec wordpress bash`
- To open a CLI shell on active database, run `docker-compose exec db mysql`

### Permissions

The `wp-content` directory must be writable by the www-data user.

## Questions, todos and known issues

- [x] Should extra tools like wp-cli and composer be wrapped in npm scripts/aliases? **_YES!_** do this.

- [x] How to handle port collisions? Can't run two instances at the same time or ports will collide. **Possible Solution?:** Don't specify ports anymore. Instead, docker-compose can map ephermeral ports on on the host. These can be revealed by running either `docker-compose ps` or `docker-compose [service] [internal-port]` (eg. `docker-compose port wordpress 80`) This should be cleaned up and masked behind a script

- [x] [phpMyAdmin](https://www.phpmyadmin.net): Yea or nay? (why not, it was really easy to add)

- [x] Linking the wp-content directory as a docker volume inadvertently creates a few extra files. These are in .gitignore, but it's still annoying. (ie. `wp-content/upgrade`, `wp-content/index.php`, all the `themes/twenty*` directories) ~~Possible solution might be flattening our theme up to the top level then linking that directly into the docker container. Or, being more selective about where we're mounting volumes~~ Mount the relevant wp-content and theme subdirectories directly instead of wp-content itself.

* [x] Can some of our wp-config add-ons be baked into the wordpress Dockerfile? Specifically the general debug stuff that gets repeated without changing.

* [ ] We probably need to build a dockerfile around wp-cli. This would include the theme setting command as well as migrating the install-missing-plugin code from the old Vagrant projects.

* [x] How to get a MySQL shell? (`docker ps` find the name of the database container, then `docker exec -it example_db_1 mysql`)

### Default ports:

For a basic up, the raw WordPress host should be available at port 8001
The build tools proxy should be available at port 8080
PHP MyAdmin should be available at port 8002

## A Few Useful Docker commands

- `docker-compose down` tears down the containers
- `docker system prune` Clean up unused containers and images
- `docker system prune -a` Clean everything, will need to download stuff again
- `docker exec -it <container> bash` Open a shell on a running container

<!-- ### Related Projects -->

### Local Development

To iterate locally, build the image using the same name as the Docker Hub remote. Docker will use the local copy.

```sh
$ docker build -t ideasonpurpose/docker-build .
```

[basic-wordpress-vagrant]: https://github.com/ideasonpurpose/basic-wordpress-vagrant
[basic-wordpress-box]: https://github.com/ideasonpurpose/basic-wordpress-box
[env-file]: https://docs.docker.com/compose/compose-file/#env_file
[composer]: https://getcomposer.org/
[docker-build]: https://github.com/ideasonpurpose/docker-build
[phpmyadmin]: https://www.phpmyadmin.net/
