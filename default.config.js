require("dotenv").config();

const pkg = require("./package.json");
const themeName = process.env.NAME || pkg.name || "theme-name";

module.exports = {
  src: `./wp-content/themes/${themeName}/src`,
  dist: `./wp-content/themes/${themeName}/dist`,
  entry: [
    "./js/main.js",
    "./js/admin.js",
    "./js/editor.js",
    "./sass/main.scss"
  ],
  publicPath: `/wp-content/themes/${themeName}/dist/`,

  // TODO: This should be automatic, maybe valid entries are: true, false, null, string (a valid url)?
  proxy:
    "http://devserver-proxy-token--d939bef2a41c4aa154ddb8db903ce19fff338b61"
};
