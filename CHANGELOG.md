### Changelog

All notable changes to this project will be documented in this file. Dates are displayed in UTC.

Generated by [`auto-changelog`](https://github.com/CookPete/auto-changelog).

#### [v0.7.8](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.7.7...v0.7.8)

- forever bumpin' those deps [`b203fec`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/b203feceab0be017f0ecac8cd8b84bfd12f149c2)
- npm audit fix [`9f586e3`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/9f586e32867e88a391dbec8b66fe7b1a2a5c8793)
- pull script permissions fix [`856c3c5`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/856c3c5941c2e7127c1eeaeea7cdb2ff379db98c)

#### [v0.7.7](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.7.6...v0.7.7)

> 10 May 2021

- update pull & permissions scripts and compose-util [`b1e1379`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/b1e137948ad043dbc7512ca8862074657be5933e)
- pull:db ownsership and path fixes [`c6fff7f`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/c6fff7fd8deab23b03dd53120b50c959fc815b46)

#### [v0.7.6](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.7.5...v0.7.6)

> 8 May 2021

- add stop script. Closes #19 [`#19`](https://github.com/ideasonpurpose/docker-wordpress-dev/issues/19)
- non-destructive bootstrap scripts. Closes #18 [`#18`](https://github.com/ideasonpurpose/docker-wordpress-dev/issues/18)
- move sort-package-json into init script [`dc6958d`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/dc6958d43515199ec7a196941b796da892a86257)
- ssh key permissions fix for hyper-V Docker Windows [`b976546`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/b976546796b7d5127a91df0978d888bbd82bd874)
- unify docker-compose file versions to 3.9 [`cf19649`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/cf19649192a56b3bf659d8c854bc6d3980794b61)

#### [v0.7.5](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.7.4...v0.7.5)

> 6 May 2021

- fix for windows pull warnings [`94e980e`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/94e980ebb865f6b880cfdb7f16c67e879dda0f53)

#### [v0.7.4](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.7.3...v0.7.4)

> 6 May 2021

- update pull/sync script to work with Kinsta [`bd115ca`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/bd115caba31e5f5a19c2b044812533d732f910ad)
- version-lock all docker images [`c9e98e9`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/c9e98e995d4d1e7d1a9ede8a7912419b9262d220)

#### [v0.7.3](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.7.2...v0.7.3)

> 5 May 2021

- optional dev-plugin volumes [`41bf686`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/41bf6867113021230a99912dc9ce0520e8792915)
- add port to pull script, for testing Kinsta [`1c29398`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/1c29398eb66c070b577fd8183f013de3ea011d95)
- Remove now-obsolete :delegated flags from volumes [`b992d8c`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/b992d8ce070c01522d722d9118162001b8306060)
- bump wordpress, composer libs [`8f588b9`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/8f588b98ea2ac6c35d22fb8c266af202045a7575)
- note about pulling on Kinsta [`ffd835d`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/ffd835dee7309ed3cf8ddf10dc9098ff9de78086)

#### [v0.7.2](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.7.1...v0.7.2)

> 8 April 2021

- fix auth in docker php composer service [`8aa78df`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/8aa78df2683230955ebb1ee6d8ae3fa941858477)
- updates [`37432b4`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/37432b4c3e37dc90cd5ac6c04b74cc251888b730)
- Fix env-vars in pull service [`ee7ef5f`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/ee7ef5f3f502f26cb7fd5631f8ea9f28ba7fb9a9)
- remove composer-oAuth token [`9d847ca`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/9d847ca7c427320128637a7ca850901beb1c2ca0)
- stop updating versions in composer.json [`083bbd7`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/083bbd7122a3242d5114d64b6e947f9f403f2712)

#### [v0.7.1](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.7.0...v0.7.1)

> 2 April 2021

- speed up permissions repair. Closes #15 [`#15`](https://github.com/ideasonpurpose/docker-wordpress-dev/issues/15)
- remove wp-social-share-links from composer.json [`0b8b829`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/0b8b8295bb6b53280bb676be1718d2df78aaa990)
- remove version from composer.json [`9abbec7`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/9abbec7e2d6ad5c01bc8cf6ceef80b355db6a78c)

#### [v0.7.0](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.6.1...v0.7.0)

> 22 March 2021

- update config for new WP base image [`a72c05e`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/a72c05ea1425b5df6abfa4828c67179395fdc5a6)
- update docker-compose [`eb407e2`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/eb407e29a42620e1c6fdbbdf03e84c98f498d79e)
- rename SSH_KEY to SSH_KEY_PATH for clarity [`8b3d7f7`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/8b3d7f7e2404a2a16f76fdfbed1d4012cdd633f3)
- bump base image to WordPress 5.7.0 [`7922ceb`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/7922ceb98c02f4225582a6b2453c08216c774f0b)

#### [v0.6.1](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.6.0...v0.6.1)

> 9 March 2021

- bump docker image versions [`12244a4`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/12244a4e754e13982a2c543038d14d34d5425d6f)

#### [v0.6.0](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.5.8...v0.6.0)

> 9 March 2021

- Add remote pull, misc updates [`edbf894`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/edbf8948861cc9cb49601f44f9b16c43cf691b4f)
- prettier [`bb39517`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/bb39517b38ac84367b4efb4eb48c18073c8a6ed2)
- Add info banner when launching phpMyAdmin [`9ab1a5b`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/9ab1a5be0e97ac20e8b33958b561cde301679009)

#### [v0.5.8](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.5.7...v0.5.8)

> 13 October 2020

- refactor and improve permissions repair [`cfd3df2`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/cfd3df2fcc46cfdd88d570696d992d32882fbde0)
- shell script linting and cleanup [`8f8d88b`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/8f8d88b7d6feaf6fd7d0f738ca76d43084eb7ecf)
- bump dependencies [`503ae12`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/503ae1286aa872fd833832ef68ce6a2d4ba94f7d)
- Add Prettier markdown override to package.json [`80f22f2`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/80f22f2e2faf1f67c16f5d7697c462ad86b0b6fa)
- more aggressive wp-content permissions fixes [`5c76e8f`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/5c76e8ff5c521fff7b1a5eeba586864f1dbd3888)
- Update README.md [`7015d5e`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/7015d5e72dfafa85258c9aaf184247e16d654501)
- bump docker-build version [`9e5cfbb`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/9e5cfbb933350325ed8a28724c7e09157015123f)

#### [v0.5.7](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.5.6...v0.5.7)

> 3 September 2020

- permissions fixes [`67362ce`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/67362ce960ee9308debee62aa141659106da4ff3)
- bump wordpress version to 5.5.1 [`a12f8a3`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/a12f8a3c14d5be21c9b01888517d70245e487c03)
- update wp-cli service user:group [`3e0f042`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/3e0f0427a59f5e3bc2f8587695dc95af48c245a9)
- logs? log? whatever [`0dcb006`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/0dcb006fcc51cb43dc92ec15fcffdeadb337a3dd)

#### [v0.5.6](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.5.5...v0.5.6)

> 13 August 2020

- more comprehensive permissions reset [`c0c3708`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/c0c3708d5c1ae8685795c105919df59c278cf082)
- bump WordPress base image to 5.5.0-php7.4 [`96b201d`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/96b201d2bcc2ca4df9bcd94d835bd699b2649bc9)
- permissions blast, wp-content ug+rwx [`0d8faf9`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/0d8faf94dd71ba1f60cf2e8336cff9e46478b5ff)
- remove dotenv [`edf17ea`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/edf17ea9bf0f685476354bd1267cc3163f9add26)
- remove license from boilerplate-package.json [`65507f5`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/65507f5f9eb0ac41a3f97efcdc51eeec4954d284)

#### [v0.5.5](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.5.4...v0.5.5)

> 12 August 2020

- fix theme activation on DB cold start [`7452227`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/74522277259d6019c037ebe20f8e8a7e062aed85)
- Add post-init message [`520c2c9`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/520c2c99e1938ba67c26f93f8306f901854e66d0)
- update README (double .gitignore) [`cb01364`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/cb01364facf3de07704853aa8ee33ba5c8497c4e)

#### [v0.5.4](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.5.3...v0.5.4)

> 6 August 2020

- merge default scripts, more permissions fixes [`e6b9c89`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/e6b9c89c759a9572fbfca86d677d33ef3b3d17ea)
- Better sorting of composer.json [`89919bd`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/89919bd597c1659c4fbbc3b10e06880d20e54dd1)
- fix theme-activate [`7df348b`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/7df348b5a697fbd593ab9e76d4568883a2bdd6c4)
- run composer:update to skip lockfile warnings [`6eaa39b`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/6eaa39b5b33df93073b39160e1bd30c9011e7b14)
- remove old comments [`799887f`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/799887f967598b565bb8dd91d01a281434e07d93)

#### [v0.5.3](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.5.2...v0.5.3)

> 6 August 2020

- GitHub Actions fix [`e0c005b`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/e0c005b1daa78d1f20b05770cb10190bc7a5327a)

#### [v0.5.2](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.5.1...v0.5.2)

> 6 August 2020

- rename action, minor readme update [`9db80b0`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/9db80b0afc27132ebd006c6e445161c50c6033a1)
- separate Docker Hub README update action [`77adb3e`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/77adb3e986e634dc51fef64ce46cfb0a198e9a5c)
- Update dockerhub.yml [`20736e2`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/20736e2d094e0170a801ce3427ca0489bf6a7f54)
- Add version to README init command, bump version script [`6d9857b`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/6d9857ba60dff58a6d09efdaf9e8f0084a116507)
- Explicitly re-apply default scripts onto package.json [`da6f52e`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/da6f52eb9229854f832a2fb2e8e2ef9fb53e215b)
- update Docker Hub readme from GitHub actions [`249059e`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/249059e98ddab8508336e35c9b769e9fde8eb2e2)
- add docker-build link to readme [`89affdd`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/89affdd73ee3dc0cf88b6b9ff422a6ac87132505)

#### [v0.5.1](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.5.0...v0.5.1)

> 4 August 2020

- Update README [`9bc4d6b`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/9bc4d6b3b284fcc4ebc7711f4e9e3a2226aa7de4)
- update readme [`38612c5`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/38612c5ff29a82ea85470cb15be424371b250e2d)
- Suppress chown 'no such file' warnings [`90a29ba`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/90a29ba228944b40405f524502924af57ea32421)

#### [v0.5.0](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.4.3...v0.5.0)

> 4 August 2020

- Massive refactor of the WordPress image & tooling [`97a4e2b`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/97a4e2bf0eaeaccee95e7d03425d735f5d6915b3)
- package.json script updates, README revisions-WIP [`a35dc55`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/a35dc5560a10e4e9aea297a1a6e08eade8d3e40a)
- sync WP image version into docker-compose [`4d76bfd`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/4d76bfda636f91789e95fb2b9624cad33d1959f0)
- create README, tweak permissions [`48d4cbc`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/48d4cbc49350fb0509afdbab7d6baceef5dce73a)
- bump image version npm script for docker-compose [`4e82f0e`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/4e82f0eeb3508764b0defd03d835e611999040d0)
- add usePolling to default config [`a447944`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/a4479448bf6706168f02dbf7cbc6150838b7fc43)
- add WSL2 Zone.Identifier to .gitignore [`c24c343`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/c24c343be9035ebac4e06c83ad05eebcf89ad166)

#### [v0.4.3](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.4.2...v0.4.3)

> 23 July 2020

- bump node stuff, tiny readme fixes [`fe618e0`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/fe618e00e45eea0c6874ee046a313099099afcbd)
- add wp user and group, update permissions [`8aa8807`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/8aa88074f2fecee2b87d5b4e3444a71b81e2d078)
- simplify volumes, bump images, npm tail log script [`9a2b63b`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/9a2b63b4adc1b4e3ff627f21ed31ec1d24fd8b1f)

#### [v0.4.2](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.4.1...v0.4.2)

> 19 June 2020

- add null github-oauth token for rate-limits. Fixes #10 [`#10`](https://github.com/ideasonpurpose/docker-wordpress-dev/issues/10)
- bump npm dependencies [`943a27e`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/943a27e79d092d9b13c84fdb5644e1c29f624d35)
- remove placeholder gulpfile [`648cdd2`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/648cdd2f109503d0a5bfc4bf7d37fc227a699383)

#### [v0.4.1](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.4.0...v0.4.1)

> 5 June 2020

- mysql:reload activates correct theme. Fixes #11 [`#11`](https://github.com/ideasonpurpose/docker-wordpress-dev/issues/11)
- readme tweaks, remove example.env [`350e445`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/350e445563c1a5550eb2700a037f581758e60ae6)
- fix themes dir permissions from entrypoint script [`bc7714d`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/bc7714da4864ee2a94cb6c6503a7d514867bc6ea)
- add mysql script to open a MySQL shell [`0375c9a`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/0375c9abe441d6a7bf5b0757d4bee1fbbda942f4)

#### [v0.4.0](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.3.2...v0.4.0)

> 17 May 2020

- add auto-changelog [`3cf7d6b`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/3cf7d6bba2e6293adcab30f829c9206e1950dd86)
- port config updates to package.json and readme [`0a202f2`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/0a202f23c6686fb7a11e05464c82867aabe2bdfe)
- add php-ext-intl, update composer.json config [`8a8eaab`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/8a8eaabe9efe40b63046d405e2299f5b77eba850)
- docker-compose updates and refinements [`c57f30a`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/c57f30a94a7bccc3e1db3512c4391bd32a96999b)
- update boilerplate stylelintrc.js, deps [`011b622`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/011b622f4c1b6cb1e849b3dc1ee3b6c0b4cf0182)
- bump WordPress to v5.4.1 [`082c8cf`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/082c8cffd4d75c834f79ceb6013c1d49b8e99c1e)
- add port to tools env, bump tools version [`8418390`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/8418390f3afa561e31506022e2b7a36864555577)

#### [v0.3.2](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.3.1...v0.3.2)

> 19 April 2020

- link GitHub build badge [`4445e4c`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/4445e4cc3c8b79caa45e12509e986122cc929677)

#### [v0.3.1](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.3.0...v0.3.1)

> 19 April 2020

- fiddling with language [`e3449fe`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/e3449fe1e5c78c6c3c89ae2da8010421c5e43406)
- add status badge to readme [`92b4277`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/92b4277c9858a0a9a322c90c1de2f0e834e3c4ca)

#### [v0.3.0](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.2.1...v0.3.0)

> 19 April 2020

- re-order a few things based on usage [`a0b6ebf`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/a0b6ebf6fa1605a03ed900622e7f1a6a30b610d0)
- dockerhub action [`1be7d0c`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/1be7d0c4d30804e12b84a0183c346b8520822d44)
- bump deps [`898c8aa`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/898c8aa640f3ef2dd8f6c2137d5bc63fa9932be8)
- switch to explicit version: wordpress:5.4.0-php7.3-apache [`e02c0d9`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/e02c0d90be01b6d26297ee9c554ebb53b919203e)

#### [v0.2.1](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.2.0...v0.2.1)

> 14 January 2020

- bump version-everything [`7e7df44`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/7e7df44b7f457f3084bdc1e0a061c7bc1771da80)

#### [v0.2.0](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.1.4...v0.2.0)

> 13 January 2020

- separate package.json scripts. Closes #9. Fixes #8 [`#9`](https://github.com/ideasonpurpose/docker-wordpress-dev/issues/9) [`#8`](https://github.com/ideasonpurpose/docker-wordpress-dev/issues/8)
- configurable development port [`620555a`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/620555a9ca54f6e04b93be45035975c5a27cc0b6)
- missing menu fix, trailing comma [`71fb54d`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/71fb54da4e1099c387fbf6f6c0c069ff12e04e69)

#### [v0.1.4](https://github.com/ideasonpurpose/docker-wordpress-dev/compare/v0.1.3...v0.1.4)

> 9 January 2020

- versioning, add trailingCommaPHP to prettier [`7c7caa4`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/7c7caa413235f9eb80987aabb44781a13a62feca)

#### v0.1.3

> 2 January 2020

- Set permissions on wp-content, should fix #3 [`#3`](https://github.com/ideasonpurpose/docker-wordpress-dev/issues/3)
- tooling updates, bump dependencies [`ce95b12`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/ce95b1233c3e4e2d0b8cf0fcb4813585803126df)
- boilerplate-tooling [`8426c8c`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/8426c8c3c8fb85daae8ed8dbf91fd64bbc110567)
- migrate templates back from GIP [`3987437`](https://github.com/ideasonpurpose/docker-wordpress-dev/commit/3987437d129561fd43803b9169dce71441728516)
