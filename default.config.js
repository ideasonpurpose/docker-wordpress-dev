require("dotenv").config();

const pkg = require("./package.json");
const themeName = process.env.NAME || pkg.name || 'theme-name';

module.exports = {
  src: `./wp-content/themes/${themeName}/src`,
  dist: `./wp-content/themes/${themeName}/dist`,
  entry: {
    index: ["./js/index.js", "./sass/main.scss"],
    admin: "./js/admin.js",
    editor: "./js/editor-blocks.js"
  },
  // TODO: Switch this back to an array once gulpfile is gone, either that or rename the
  //       stylesheet entry file to prevent writing an empty js file
  entry: ["./js/index.js", "./js/admin.js", "./js/editor-blocks.js"],
  publicPath: `/wp-content/themes/${themeName}/dist/`,

  // TODO: This should be automatic, maybe valid entries are: true, false, null, string (a valid url)?
  proxy:
    "http://devserver-proxy-token--d939bef2a41c4aa154ddb8db903ce19fff338b61"
};
