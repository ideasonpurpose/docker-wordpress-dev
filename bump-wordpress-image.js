/**
 * This script matches the Docker ideasonpurpose/wordpress image version
 * specified in boilerplate-tooling/docker-compose.yml to the version in
 * package.json. It should be run from the 'version' lifecycle hook to access
 * the updated c version in package.json.
 */
const path = require("path");
const replace = require("replace-in-file");
const chalk = require("chalk");
const { version } = require("./package.json");

/**
 * @var regex is based on the officially recommended semver regex
 * https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
 */
const regex = /ideasonpurpose\/wordpress:(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?/gi;

const results = replace.sync({
  from: regex,
  to: `ideasonpurpose/wordpress:${version}`,
  files: [
    "./boilerplate-tooling/docker-compose-util.yml",
    "./boilerplate-tooling/docker-compose.yml",
    "./README.md",
  ],
});

results.map(({ file }) => {
  console.log(
    "Updated image in",
    chalk.magenta(path.relative(".", file)),
    "to",
    chalk.cyan(`ideasonpurpose/wordpress:${version}`)
  );
});
