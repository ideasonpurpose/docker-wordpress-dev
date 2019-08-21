# WordPress local development with Docker

This project replaces both the [basic-wordpress-vagrant][] and [basic-wordpress-box][] projects with a Docker-based workflow. It's much lighter than Vagrant, faster to spin up and inherently cross-platform.

> ### _Please note: This project is a work in progress and changing rapidly_

## Goals

Local development and maintenance. After reviewing dozens of WordPress-Docker projects, one feature always seemed to be missing: How to use these projects to maintain an existing site

Starting a vanilla WordPress project on Docker is not difficult, but apparently setting up a populated local development environment is. This project aims to chainge that. Our primary use case is to enable fast iteration for exisitng sites. With cached docker images, we should be able to go from a database dump and cloned codebase to a complete, portable and cross-platform development environment in a few seconds.

## Usage

For now, copy the `docker-compose.yml` file to the root of the project. If not running from npm scripts, create a `.env` file containing the following:

```env
npm_package_name=project-name
```

Using npm's naming conventions means npm scripts work by default, the value should match the "name" property of package.json.

Get running in three steps:

1. Copy your database dumpfile into a top-level `_db` directory, be sure the file has a `.sql` extension.

2. Clone your theme files into `./wp-content/themes/project-name`

3. Run the following:
   ```
   docker-compose run -p 8080:8080  --rm tools npm run devserver
   ```

When it finishes, you'll have a Webpack DevServer running at [localhost:8080](http://localhost:8080)

The first run make take some time as Docker downloads the necessary images. Subsequent runs will only take a few seconds.

To stop the server type **control-c**. To stop docker, run `docker-compose down` which will teardown the virtual network and stop any active containers.

<!--
We're also watching the [Docker app](https://github.com/docker/app) project and may be able to further simplifiy this by wrapping this project in an app description later on.
-->

## Dockerfile

The Dockerfile is based on the official WordPress image. We add [Xdebug](https://xdebug.org/), the [ImageMagick](http://www.imagemagick.org/) PHP extension and enable all PHP debug settings.

## Docker-compose

The `docker-compose.yml` file builds on our Dockerfile, adds a name-based reverse-proxy, configures WordPress for development (all debugging enabled), enables the default theme links Composer and wp-cli then optionally pre-loads the database from a dumpfile.

## Package.json scripts (TODO)

Launching Docker with package.json scripts wraps up several docker configuratiojns and enables ome nice lifeccyle add-ons like package-named test domains, post-launch /etc/hosts rewrites and some post-instanciation confgurations like setting the theme and adding default users.

<!--
This also alloows for specifying the [project name](https://docs.docker.com/compose/reference/envvars/#compose_project_name), which is very nice to have down the road when sorting through Docker's leftovers. We set this to match the package's `name`.
-->

## Conventions

Whenever possible, named settings are derived from the `name` property in package.json. The docker-compose file contains sensible defaults, but taking advantage of the package.json scripts provides an even smoother developer experience.

### Database dumpfiles

Put MySQL dumpfiles in a top-level `_db` directory to populate the development database on `docker-compose up`. The [MySQL Docker image](https://hub.docker.com/_/mysql#initializing-a-fresh-instance) will load all `*.sql` files from that directory in alphabetical order. Later files will overwrite earlier ones.

## Included Tools, Commands, etc.

Calling `docker-compose up -d` will run everything. To discover ports afterwards, run `docker-compose ps`. To clean up and deactivate any active containers, run `docker-compose down`.

### MySQL

The MySQL command like client is available whenever the docker images are running. To access it, run this:

```sh
$ docker-compose exec db mysql
```

### wp-cli

WP-cli doesn't run as a sevice, but the imasge is pre-configured by the compose file to this specific WordPress instance. To access the command line, use `run` instead of `exec`, like this:

```sh
$ docker-compose run --rm wp-cli user list
```

### Composer

Similar to wp-cli, [Composer][] is available as a pre-configiured image.
Common commands like `require`, `install` or `update` can be run directly on the project's root directory like:

```sh
$ docker-compose run --rm composer update
```

For an interactive shell, call `bash` instead:

```sh
$ docker-compose run --rm composer bash
```

### phpMyAdmin

A phpMyAdmin installation is available on port `13306` of `localhost` or the local `[project-name].test` domain.

<!--
## Advantages

This project also bundles in our [docker-build toolchain][docker-build]. This has a number of advantages over including a gulpfile or webpack config in the project root. First and foremost, it encapsulates all the node dependencies, leaving only what's relevant to the projec tin niode_modules, instead of several thousand tool-related dependencies.
-->

## Windows Notes

VirtualBox and earlier versions of Docker [can not be installed simultaneously on Windows](https://technology.amis.nl/2017/07/17/virtualization-on-windows-10-with-virtual-box-hyper-v-and-docker-containers/).

> And the one finding that took longest to realize: Virtual Box will not work if Hyper-V is enabled. So the system at any one time can only run Virtual Box or Hyper-V (and Docker for Windows), not both. Switching Hyper-V support on and off is fairly easy, but it does require a reboot

## No more hostnames

When working with Vagrant, we used the vagrant hostmanager plugin to set up and point a project-name.test domain at our dev site. This was nice whjen working on one computer, but the reality bnow is that we're working on many all the time. Whatever the site is being developed on, it's likely being previewed on a handful of different desktop and mobile devices where that lovely development domain is irrelevant.

So, despite fantastic, cross-platform solutions like [Hostile](https://www.npmjs.com/package/hostile), we're dropping `*.test` development domains in favor of proxying through the Webpack DevServer.

## Notes

> todo: move these somewhere

- The wp-content/debug.log file should be writeable by the web user. If logs aren't being written, try `chmod a+w wp-content/debug.log`.

- All scripts are assumed to require jQuery and will include jQuery as a dependency. It's very difficult to get jQuery _out_ or WordPress, so instead of bundling in a second copy of the library, we just use what's there and assume it will already have been required by something else. (TODO: check this)

## Questions, todos and known issues

- [ ] Should extra tools like wp-cli and composer be wrapped in npm scripts/aliases? **_YES!_** do this.

- [x] How to handle port collisions? Can't run two instances at the same time or ports will collide. **Solution:** We're not specifying ports anymore. Instead, docker-compose maps ephermeral ports on on the host. These can be revealed by running either `docker-compose ps` or `docker-compose [service] [internal-port]` (eg. `docker-compose port wordpress 80`) This should be cleaned up and masked behind a script

- [x] [phpMyAdmin](https://www.phpmyadmin.net): Yea or nay? (why not, it was really easy to add)

- [ ] Linking the wp-content directory as a docker volume inadvertently creates a few extra files. These are in .gitignore, but it's still annoying. (ie. `wp-content/upgrade`, `wp-content/index.php`) Possible solution might be flattening our theme up to the top level then linking that directly into the docker container.

- [x] Can some of our wp-config add-ons be baked into the wordpress Dockerfile? Specifically the general debug stuff that gets repeated without changing.

- [ ] We probably need to build a dockerfile around wp-cli. This would include the theme setting command as well as migrating the install-missing-plugin code from the old Vagrant projects.

- [ ] How to get a MySQL shell?

<!-- --- -->

[basic-wordpress-vagrant]: https://github.com/ideasonpurpose/basic-wordpress-vagrant
[basic-wordpress-box]: https://github.com/ideasonpurpose/basic-wordpress-box
[env-file]: https://docs.docker.com/compose/compose-file/#env_file
[composer]: https://getcomposer.org/
[docker-build]: https://github.com/ideasonpurpose/docker-build
