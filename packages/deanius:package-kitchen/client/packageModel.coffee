#try this renaming out
Recipe = worksheet

#TODO allow changes to this model through a GUI, separate user parts
MeteorPackage = new Recipe(
  atmosphereName: ''
  githubName: ''
  packageName: ''
  version: '0.1.0'
  demoUrl: null
  summary: 'Description of package amazingness'
  'export': 'log'
  packageType: 'shared'
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
  extension: ->
    if @transpiler == 'coffeescript'
      return '.coffee'
    if @transpiler == 'es6'
      return '.next.js'
    '.js'
  fullPackageName: ->
    @atmosphereName + ':' + @packageName
  gitProject: ->
    @githubName + '/meteor-' + @packageName
  gitPath: ->
    'https://github.com/' + @gitProject
  travisBadgeMarkdown: ->
    '[![Build Status](https://secure.travis-ci.org/' + @gitProject + '.png?branch=master)](https://travis-ci.org/' + @gitProject + ')'
  testCode: ->
    if @testFramework == 'tinytest'
      return 'Tinytest.add("' + @packageName + '", function (test) {\n  test.equal(true, true);\n});'
    if @testFramework == 'mocha'
      return 'describe("' + @packageName + '", function () {\n  it("should be awesome", function (done) {\n    assert.equal(1,2);\n  });\n});'
    return
  fileLocation: ->
    if @packageType == 'shared'
      return '["client", "server"]'
    else if @packageType == 'client'
      return '["client"]'
    else if @packageType == 'server'
      return '["server"]'
    return

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

  exportSuggestion: ->
    @code?.match(/^(\w+)\s?=/m)?[1] ? ''
)


AmplifyProperty = ->
  propertyNames = arguments
  Meteor.startup ->
    for propertyName in propertyNames
      storedValue = SessionAmplify.get propertyName
      if storedValue?
        MeteorPackage[propertyName] = storedValue

      Tracker.autorun ->
        SessionAmplify.set propertyName, MeteorPackage[propertyName]

AmplifyProperty 'githubName', 'atmosphereName'

FileDescription = (name, type, content) ->
  fileName: name
  extension: type
  path: -> "#{ name }.#{ type }"
  content: content

MeteorPackage.files = new Recipe(
  readmeContent: ->
    text = """
# #{ MeteorPackage.fullPackageName }
#{ MeteorPackage.summary }

"""
    if MeteorPackage.demoUrl?
      text += "See a demo at [#{ MeteorPackage.demoUrl }](#{ MeteorPackage.demoUrl })\n"

    text += """
## Installation
```
meteor add #{ MeteorPackage.fullPackageName }
```

## Description
Add something like *#{ MeteorPackage.summary }*
"""
    return text

  packageJsContent: -> """
Package.describe({
  name: "#{ MeteorPackage.fullPackageName }",
  summary: "#{ MeteorPackage.summary }",
  version: "#{ MeteorPackage.version }",
  git: "#{ MeteorPackage.gitPath }"
});

Package.onUse(function (api) {
  api.versionsFrom("#{ MeteorPackage.requiredMeteorVersion }");
  api.use([#{ MeteorPackage.meteorPackageDependencies.map((dependency) -> '"' + dependency.name + '"').join(", ") }]);
  {{> apiFiles }}
  api.export("{{ export }}");
});
"""

  readme: -> FileDescription "README", "md", @readmeContent
  packageJs: -> FileDescription "package", 'js', @packageJsContent

  allFiles: -> [ @readme, @packageJs ]
)