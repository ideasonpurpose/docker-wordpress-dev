/**
 * Future node versions should import package.json directly:
 *   import packageJson from "./package.json" with { type: "json" };
 *
 * In the current node.js LTS v20, importing JSON throws the following warnings:
 *   (node:14509) ExperimentalWarning: Importing JSON modules is an experimental feature and might change at any time
 *   (Use `node --trace-warnings ...` to show where the warning was created)
 *
 * NOTE: This file does not work if the build runs from Docker. Inside a Docker volume, the
 * theme name pulls instead from the docker image's package.json file, which will probably
 * create a theme named 'iop-build-tools'.
 */
import { readFileSync } from "fs";
const packageJson = JSON.parse(readFileSync("./package.json"));
// import packageJson from "./package.json" with { type: "json" };

const { name: themeName } = packageJson;

export default {
  src: `./wp-content/themes/${themeName}/src`,
  dist: `./wp-content/themes/${themeName}/dist`,
  entry: ["./js/main.js", "./js/admin.js", "./js/editor.js"],
  publicPath: `/wp-content/themes/${themeName}/dist/`,

  sass: "sass-embedded",
  esTarget: "es2020",

  devtool: "source-map",
};
