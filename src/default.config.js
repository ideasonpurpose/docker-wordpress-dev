import { readPackageUp } from "read-package-up";
const themeName = (await readPackageUp()).packageJson.name;

export default {
  src: `./wp-content/themes/${themeName}/src`,
  dist: `./wp-content/themes/${themeName}/dist`,

  entry: ["./js/main.js", "./js/admin.js", "./js/editor.js"],

  publicPath: `/wp-content/themes/${themeName}/dist/`,

  // sass: "sass-embedded",
  // esTarget: "es2020",

  devtool: "source-map",
};
