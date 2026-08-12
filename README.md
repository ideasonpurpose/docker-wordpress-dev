# WordPress local development with Docker

<h4>
Version 2.0.1
<!-- WPVERSION -->- WordPress 7.0.2
</h4>

[![Docker Pulls](https://img.shields.io/docker/pulls/ideasonpurpose/wordpress?logo=docker&logoColor=white)](https://hub.docker.com/r/ideasonpurpose/wordpress)
[![Push to DockerHub](https://img.shields.io/github/actions/workflow/status/ideasonpurpose/docker-wordpress-dev/push-to-dockerhub.yml?logo=github&logoColor=white&label=Push%20to%20DockerHub)](https://github.com/ideasonpurpose/docker-wordpress-dev/actions/workflows/push-to-dockerhub.yml)

## About

A very-fast, tuned WordPress runtime image, built on the official WordPress image, currently **[v7.0.2](https://hub.docker.com/_/wordpress)** (PHP 8.4 / Apache). Designed to spin up quickly for a better local development experience.

This image is part of a larger development toolchain. Project scaffolding, `docker-compose`, webpack, and npm workflow scripts (`start`, bootstrap, database commands, etc.) are provided by the companion package [@ideasonpurpose/build-tools-wordpress](https://www.npmjs.com/package/@ideasonpurpose/build-tools-wordpress).

Avalable as [**ideasonpurpose/wordpress**](https://hub.docker.com/r/ideasonpurpose/wordpress) from DockerHub.

## Getting Started

Create or update a project with the build-tools package:

```bash
npx @ideasonpurpose/build-tools-wordpress init        # new project
npx @ideasonpurpose/build-tools-wordpress refresh     # update existing project
```

See that package's documentation for environment setup, `docker-compose.yml`, database commands, webpack config, and all development workflows.

## What’s in the Image

### PHP & Extensions

- **Xdebug** — debug and profile modes, triggered by `XDEBUG_PROFILE` / `XDEBUG_TRIGGER` cookies/params
- **Memcached** — installed and enabled
- **OPcache** — enabled with development-friendly settings (`validate_timestamps=1`, `revalidate_freq=0`)

### PHP Configuration

| Setting               | Value |
| --------------------- | ----- |
| `upload_max_filesize` | 100M  |
| `post_max_size`       | 100M  |
| `max_execution_time`  | 600   |
| `memory_limit`        | 512M  |
| `display_errors`      | on    |

### Debugging Tools

- **[wp-cli](https://wordpress.org/cli/)**
- **[Symfony VarDumper](https://symfony.com/doc/current/components/var_dumper.html)** and **[Kint](https://kint-php.github.io/kint/)** — auto-loaded via `debug_loader.php` for rich `dump()` output
- **`info.php`** — `phpinfo()` at `/info.php`
- **`xdebug.php`** — `xdebug_info()` at `/xdebug.php`
- **Debug log** — written to `/var/log/wordpress/debug.log`

### Users & Permissions

A `wp` user (UID 1000) is created and added to the `www-data` group. Both Apache and PHP are configured with `umask 002` so new files are group-writable.

### IPTables Workaround

WordPress internal requests to external ports can fail in Docker. The entrypoint remaps the ephemeral port range (49153–65535) back to port 80. This requires `NET_ADMIN` capability (`cap_add: [NET_ADMIN]` in compose).

### SSH & rsync

OpenSSH client and rsync are installed for the `pull` script (see below). SSH is configured to use `/ssh_keys/id_rsa` with strict host key checking disabled.

## Environment Variables

### WordPress Runtime

| Variable                | Default     | Description        |
| ----------------------- | ----------- | ------------------ |
| `WORDPRESS_DB_HOST`     | `db:3306`   | Database host      |
| `WORDPRESS_DB_USER`     | `wordpress` | Database user      |
| `WORDPRESS_DB_PASSWORD` | `wordpress` | Database password  |
| `WORDPRESS_DB_NAME`     | `wordpress` | Database name      |
| `WORDPRESS_DEBUG`       | `1`         | Enables `WP_DEBUG` |

### WordPress Config (via `wp-config-extra.php`)

| Variable              | Effect                                                         |
| --------------------- | -------------------------------------------------------------- |
| `WP_ENVIRONMENT_TYPE` | Sets `WP_ENVIRONMENT_TYPE` (default: `development`)            |
| `WP_MULTISITE`        | Enables multisite constants (`MULTISITE`, `SUBDOMAIN_INSTALL`) |

When `WP_DEBUG` is enabled, additional constants are set: `WP_DEBUG_LOG`, `WP_DEBUG_DISPLAY`, `WP_DEVELOPMENT_MODE` (`theme`), `SCRIPT_DEBUG`, and `SAVEQUERIES`.

### SSH / Pull

| Variable             | Description                                                           |
| -------------------- | --------------------------------------------------------------------- |
| `SSH_LOGIN`          | Connection string (`user@host` or `user@host -p port`)                |
| `SSH_USER`           | Overrides user from `SSH_LOGIN`                                       |
| `SSH_HOST`           | Overrides host from `SSH_LOGIN`                                       |
| `SSH_PORT`           | Overrides port from `SSH_LOGIN` (default: 22)                         |
| `SSH_WP_CONTENT_DIR` | Path to remote `wp-content` (default: `sites/${SSH_USER}/wp-content`) |
| `SSH_KEY_PATH`       | Local path to private key, passed as a Docker secret                  |

Secrets are passed to the container as `/run/secrets/SSH_KEY`. The entrypoint copies the key to `/ssh_keys/id_rsa`.

### wp-cli

| Variable            | Default             |
| ------------------- | ------------------- |
| `WP_CLI_CACHE_DIR`  | `/tmp/wp-cli-cache` |
| `WP_CLI_ALLOW_ROOT` | `1`                 |

## In-Image Utilities

### pull

Syncs data from a remote server. Called with a subcommand:

```
pull database     Sync remote mysql.sql to _db/
pull plugins      Sync remote wp-content/plugins/
pull uploads       Sync current year's uploads (or specify year)
pull uploads all   Sync all uploads
```

Requires SSH credentials configured via the environment variables above. Private keys are handled as [Docker Secrets](https://docs.docker.com/compose/compose-file/compose-file-v3/#secrets) — set `SSH_KEY_PATH` in `.env` to a local private key.

Works with WP Engine and Kinsta. For Kinsta, database dumps must be created manually via cron (Kinsta doesn't store regular snapshots in wp-content):

```cron
37 * * * * mysqldump --default-character-set=utf8mb4 -udb_user -pdb_password db_name > ~/public/wp-content/mysql.sql
```

Kinsta and WP Engine nginx configurations will not serve `*.sql` files to web requests. The `db_user`, `db_password`, and `db_name` values are already in `wp-config.php`.

### permissions

Corrects ownership and permissions for known project files. Called with `OWNER_GROUP` set to `"$UID:$GID"`. Iterates over top-level tooling files, `_db`, `wp-content`, and ACF JSON directories.

#### macOS Note

On macOS hosts, Docker volume permission changes add extended attributes (`com.docker.grpcfuse.*`) rather than modifying actual file modes. Run `ls -la@` or `xattr -l <file>` to inspect them.

## Debugging

### Debug Log

With `WP_DEBUG` enabled, the log is written to `/var/log/wordpress/debug.log`. From a compose project, view it with `docker compose exec wordpress tail -f /var/log/wordpress/debug.log`.

### Xdebug

Xdebug is configured for both debug and profile modes, triggered by `XDEBUG_PROFILE` or `XDEBUG_TRIGGER` cookies/query parameters.

- **IDE debugging** — client host is `host.docker.internal`, port `9003`
- **Profiling** — add `XDEBUG_PROFILE=1` to any request. Output files go to `/tmp/xdebug` in the container

## Updating WordPress

The base image provides a specific WordPress version, but running sites can upgrade via the wp-admin dashboard or wp-cli, including [pre-release](https://wordpress.org/download/releases/#betas) versions:

```sh
wp core update --version=7.1-RC2
```

Versions can be rolled back by removing the Docker `*_wp` volume.

### Bumping the Image Version

To update this image to the latest stable WordPress:

```sh
npm run bump
```

This queries the WordPress releases API and Docker Hub, then updates `wp-version.json`, the Dockerfile, and the README. To target a pre-release, manually edit `wp-version.json`.

## Local Development

Build the image locally (Docker will use the local copy over the remote):

```sh
docker build . --tag ideasonpurpose/wordpress:dev
```

### Shell Scripts

Scripts in `bin/` are checked with [ShellCheck](https://www.shellcheck.net/) and formatted with [shfmt](https://github.com/mvdan/sh):

```sh
npm run shfmt
```

### CI/CD

- **`push-to-dockerhub.yml`** — On version tags (`v*`), builds multi-arch images (`linux/amd64`, `linux/arm64`) and pushes to Docker Hub. Tags include semver, WordPress version, and SHA.
- **`update-dockerhub-readme.yml`** — On version tags, syncs this README to Docker Hub.

## Docker Maintenance

Useful commands when working with this image:

- `docker compose down` — Tear down containers
- `docker system prune` — Remove unused containers and images
- `docker system prune -a` — Full cleanup (requires re-downloading images)
- `docker ps` — List running containers
- `docker exec -it <container> bash` — Open a shell on a running container

<!-- START IOP CREDIT BLURB 2026-07-->

## &nbsp;

#### Brought to you by IOP

| <a href="https://www.ideasonpurpose.com"><img src="https://raw.githubusercontent.com/ideasonpurpose/ideasonpurpose/master/iop-logo-white-on-black-88px.png" width="44" height="44" align="top" alt="IOP Logo"></a> <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | This project is actively developed and used in production at <a href="https://www.ideasonpurpose.com">Ideas On Purpose</a>. <br>&nbsp; |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |

<!-- END IOP CREDIT BLURB -->
