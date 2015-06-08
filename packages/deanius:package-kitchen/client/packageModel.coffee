Amplifier =
  Properties: []

Amplifier.TrackProperty = ->
  propertyNames = arguments

  @Properties.concat(propertyNames)

  Meteor.startup ->
    propertyNames.forEach (propertyName) ->
      Tracker.autorun ->
        SessionAmplify.set propertyName, PackageKitchen[propertyName]

Amplifier.Load = ->
  packageData = {}
  @Properties.forEach (propertyName) ->
    storedValue = SessionAmplify.get propertyName
    if storedValue?
      packageData[propertyName] = storedValue

  console.log "Loaded ", packageData

  return packageData



# Amplifier.TrackProperty 'githubName', 'atmosphereName'

#try this renaming out
Recipe = worksheet

#TODO allow changes to this model through a GUI, separate user parts
PackageKitchen =
  TRANSPILERS:
    COFFEESCRIPT: 'coffeescript'
    ECMA6: 'ecma6'
    NONE: null
  TESTING_FRAMEWORKS:
    TINYTEST: 'tinytest'
    MOCHA: 'mocha'
    MUNIT: 'munit'
    NONE: null

PackageKitchen.DefaultValues =
  atmosphereName: ''
  githubName: ''
  packageName: ''
  version: '0.1.0'
  demoUrl: null
  summary: ''
  exports: []
  scope: 'shared'
  useTravis: true
  meteorPackageDependencies: [
    name: "meteor"
  ,
    name: "ddp"
  ,
    name: "jquery"
  ]
  requiredMeteorVersion: '1.0.1'
  testFramework: 'tinytest'
  code: ''
  transpiler: null

PackageKitchen.PropertyFunctions =
  extension: ->
    if @transpiler is PackageKitchen.TRANSPILERS.COFFEESCRIPT
      return 'coffee'
    if @transpiler is PackageKitchen.TRANSPILERS.ECMA6
      return 'next.js'
    'js'
  fullPackageName: ->
    @atmosphereName + ':' + @packageName
  gitProject: ->
    @githubName + '/meteor-' + @packageName
  gitPath: ->
    'https://github.com/' + @gitProject
  travisBadgeMarkdown: ->
    '[![Build Status](https://secure.travis-ci.org/' + @gitProject + '.png?branch=master)](https://travis-ci.org/' + @gitProject + ')'

  fileLocation: ->
    if @scope == 'shared'
      return '["client", "server"]'
    else if @scope == 'client'
      return '["client"]'
    else if @scope == 'server'
      return '["server"]'
    return

  exportSuggestion: ->
    @code?.match(/^(\w+)\s?=/m)?[1] ? ''

PackageKitchen.FilesFor = (kitchenPackage) ->
  FileDescription = (options) ->
    directory: options.directory
    fileName: options.name
    extension: options.extension ? kitchenPackage.extension
    scope: options.scope
    path: ->
      (if @directory? then "#{ @directory }/" else "") +
      (if @directory? and @scope? then "#{ @scope }/" else "") + # assuming files in sub-folders are scope-specific
      "#{ @fileName }.#{ @extension }"
    content: options.content

  new Recipe(
    readmeContent: (options) ->
      options ?= {}

      text = """
# #{ kitchenPackage.fullPackageName }
#{ kitchenPackage.summary }

"""
      if kitchenPackage.useTravis
        if options.production
          text += "" # todo
        else
          text += "[![Build Status](/travis-passing.svg)](https://travis-ci.org/)\n"

      if kitchenPackage.demoUrl?
        text += "See a demo at [#{ kitchenPackage.demoUrl }](#{ kitchenPackage.demoUrl })\n"
  
      text += """
## Installation
```
meteor add #{ kitchenPackage.fullPackageName }
```

## Description
Add something like *#{ kitchenPackage.summary }*
"""

      return text

    packageJsContent: ->
      packageJs = """
Package.describe({
  name: "#{ kitchenPackage.fullPackageName }",
  summary: "#{ kitchenPackage.summary }",
  version: "#{ kitchenPackage.version }",
  git: "#{ kitchenPackage.gitPath }"
});

Package.onUse(function (api) {
  api.versionsFrom("#{ kitchenPackage.requiredMeteorVersion }");
  api.use([#{ kitchenPackage.meteorPackageDependencies.map((dependency) -> '"' + dependency.name + '"').join(", ") }]);
  {{> apiFiles }}

"""

      kitchenPackage.exports.forEach (exportIdentifier) ->
        packageJs += "  api.exports('#{ exportIdentifier }');\n";

      packageJs += """
});

Package.onTest(function (api) {

"""
      switch kitchenPackage.testFramework
        when PackageKitchen.TESTING_FRAMEWORKS.TINYTEST
          packageJs += '  api.use("tinytest");\n'
        when PackageKitchen.TESTING_FRAMEWORKS.MOCHA
          packageJs += '  api.use("mike:mocha-package", "practicalmeteor:chai"]);\n'


      packageJs += "  api.use(\"#{ kitchenPackage.fullPackageName }\");\n"

      @testFiles?.forEach (testFile) ->
        packageJs += "  api.use('#{ testFile.path() }'"
        if testFile.scope isnt 'shared'
          packageJs += ", '#{ testFile.scope }'"
        packageJs += ");\n"

      packageJs += "});"

      return packageJs

    testContent: ->
      switch kitchenPackage.testFramework
        when PackageKitchen.TESTING_FRAMEWORKS.TINYTEST
          if kitchenPackage.transpiler is PackageKitchen.TRANSPILERS.COFFEESCRIPT
            """
Tinytest.add "#{ kitchenPackage.packageName }", (test) ->
  test.equal true, true
"""
          else
            """
Tinytest.add("#{ kitchenPackage.packageName }", function (test) {
  test.equal(true, true);
});
"""

        when PackageKitchen.TESTING_FRAMEWORKS.MOCHA
          if kitchenPackage.transpiler is PackageKitchen.TRANSPILERS.COFFEESCRIPT
            """
describe "#{ kitchenPackage.packageName }", ->
  it "should be awesome", (done) ->
    Meteor.setTimeout(->
      assert.equal 1, 1
      done()
    , 100)
"""
          else
            """
describe("#{ kitchenPackage.packageName }", function () {
  it("should be awesome", function (done) {
    Meteor.setTimeout(function () {
      assert.equal(1, 1);
      done();
    }, 100);
  });
});
"""

    readme: -> FileDescription(
      name: "README"
      extension: "md"
      content: @readmeContent
    )
    packageJs: -> FileDescription(
      name: "package"
      extension: 'js'
      content: @packageJsContent
    )
    testFiles: (locations) ->
      locations = if kitchenPackage.scope is 'shared' then ['shared', 'client', 'server'] else [ kitchenPackage.scope ]

      locations.map (location) =>
        FileDescription(
          directory: "tests"
          name: "test"
          # extension determined by package
          content: @testContent
          scope: location
        )

    travis: -> FileDescription(
      name: ".travis"
      extension: 'yml'
      content: ->
        """
sudo: required
language: node_js
node_js:
  - "0.10"

before_install:
  - "curl -L http://git.io/ejPSng | /bin/sh"
"""
    )


    allFiles: ->
      files = [ @readme, @packageJs ]
        .concat(@testFiles)

      if kitchenPackage.useTravis
        files.push(@travis)

      return files

)
    
PackageKitchen.GetPackage = ->
  _package = new Recipe(
    _.extend {}, Amplifier.Load(), PackageKitchen.DefaultValues, PackageKitchen.PropertyFunctions
  )
  
  _package.files = PackageKitchen.FilesFor(_package)

  return _package
  


#  apiFiles: ->
#    [ {
#      path: @packageType + '/index' + @extension
#      where: @fileLocation
#      contents: @code
#      template: Template.code
#    } ]
#  testFiles: ->
#    if !@testFramework
#      return []
#    [ {
#      path: 'tests/' + @packageType + '/index' + @extension
#      where: @fileLocation
#      contents: @testCode
#      template: Template.code
#    } ]
#  allFiles: ->
#    [
#      {
#        path: 'README.md'
#        template: Template.readme
#      }
#      {
#        path: 'package.js'
#        template: Template.packageJs
#      }
#    ].concat(@apiFiles).concat(@testFiles).concat [ {
#      path: '.travis.yml'
#      template: Template.travis
#    } ]
#  allFilesRendered: ->
#    @allFiles.map (file) =>
#
#      path: file.path
#      # contents: file.contents or Blaze.toHTMLWithData(file.template, this)


