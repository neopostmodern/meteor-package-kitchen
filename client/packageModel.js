//try this renaming out
var Recipe = worksheet;

//TODO allow changes to this model through a GUI, separate user parts
var packageModel = new Recipe({
  atmosphereName: "deanius",
  githubName: "chicagogrooves",
  packageName: "new-package",
  version: "0.1.0",
  demoUrl: "",

  summary: "Description of package amazingness",
  "export": "log",

  packageType: "shared", // client, server, or shared
  packageDeps: '["meteor", "ddp", "jquery"]',

  testFramework: "tinytest", // null, tinytest, mocha
  code: "/* global log:true */\nlog = console.log.bind(console);",
  transpiler: "",
  extension: function () {
    if (this.transpiler === "coffeescript")
      return ".coffee";
    if (this.transpiler === "es6")
      return ".next.js";

    return ".js";
  },

  fullPackageName: function () {
    return this.atmosphereName + ":" + this.packageName;
  },

  gitProject: function () {
    return this.githubName + "/meteor-" + this.packageName;
  },

  gitPath: function () {
    return "https://github.com/" + this.gitProject;
  },

  travisBadgeMarkdown: function () {
    return "[![Build Status](https://secure.travis-ci.org/" +
      this.gitProject +
      ".png?branch=master)](https://travis-ci.org/" +
      this.gitProject + ")"
  },

  // the test code to start us off with
  testCode: function () {
      if(this.testFramework == "tinytest")
        return "Tinytest.add(\"" + this.packageName + "\", function (test) {\n  test.equal(true, true);\n});";
      if(this.testFramework == "mocha")
        return "describe(\"" + this.packageName + "\", function () {\n  it(\"should be awesome\", function (done) {\n    assert.equal(1,2);\n  });\n});"
  },

  fileLocation: function () {
    if (this.packageType==="shared")
      return '["client", "server"]';
    else if (this.packageType==="client")
      return '["client"]';
    else if (this.packageType==="server")
      return '["server"]';
  },

  apiFiles: function () {
    return [{
      path: this.packageType + "/index" + this.extension,
      where: this.fileLocation,
      contents: this.code,
      template: Template.code
    }]
  },

  testFiles: function () {
    if (! this.testFramework ) return [];
    return [{
      path: 'tests/' + this.packageType + '/index' + this.extension,
      where: this.fileLocation,
      contents: this.testCode,
      template: Template.code
    }];
  },

  allFiles: function () {
    return [
      {
        path: "README.md",
        template: Template.readme
      },
      {
        path: "package.js",
        template: Template.packageJs
      }
    ]
    .concat(this.apiFiles)
    .concat(this.testFiles)
    .concat([
      {
        path: ".travis.yml",
        template: Template.travis
      }
    ]);
  },

  allFilesRendered: function () {
    return this.allFiles.map(function (file) {
      return {
        path: file.path,
        contents: file.contents || Blaze.toHTMLWithData(file.template, packageModel)
      };
    });
  },

  exportSuggestion: function () {
    var match = this.code.match(/^(\w+)\s?=/m);
    return match ? match[1] : "";
  }
});

this.packageModel = packageModel;
