module.exports = {
  extends: ["stylelint-config-rational-order", "stylelint-config-prettier"],
  plugins: ["stylelint-prettier"],
  rules: {
    // "at-rule-empty-line-before": null,
    "prettier/prettier": true,
    "plugin/rational-order": [
      true,
      { "empty-line-between-groups": true,
      // TODO:  The next line might fix  https://github.com/constverum/stylelint-config-rational-order/issues/16
      //        add to this file: https://github.com/constverum/stylelint-config-rational-order/blob/master/config/extendedStylelintOrderConfig.js
      // go make a pull request
      severity: "warning"
     }
    ]
  }
};
