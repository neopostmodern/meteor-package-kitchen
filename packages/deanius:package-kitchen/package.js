Package.describe({
  name: "deanius:package-kitchen",
  summary: "Easy bootstrapping of Meteor packages",
  version: "1.2.5",
  git: "https://github.com/chicagogrooves/meteor-package-kitchen",
});

Npm.depends({
  "mkdirp": "0.5.0"
});

Package.onUse(function(api) {
  api.versionsFrom("1.0.2");
  api.use(["meteor", "spacebars", "templating", "underscore"]);
  api.use("coffeescript", "client");
  api.use("meteorhacks:npm");
  api.use("deanius:worksheet@1.0.0");
  api.use("deanius:promise@2.0.4");
  api.use("mrt:session-amplify@0.1.0");
  // use it, and make its exports available in the app that includes us
  api.imply("perak:markdown@1.0.4");

  // api.addFiles("server/methods.js", ["server"]);
  api.export("PackageKitchen", "client");
  api.addFiles("client/jszip.js", ["client"]);
  api.addFiles("client/zip.coffee", ["client"]);
  api.addFiles("client/packageModel.coffee", ["client"]);

  api.export("PackageKitchen", "client");
});
