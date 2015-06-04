_updatePackage = ->

  parseDeps = (depsString) ->
    if depsString is ""
      return []

    return depsString.split(/\s*,\s*/)


#  Meteor.defer ->
#    SessionAmplify.set("atmosphereName", $("[name=atmosphereName]").val())
#    SessionAmplify.set("githubName", $("[name=githubName]").val())
#    SessionAmplify.set("packageName", $("[name=packageName]").val())
#    SessionAmplify.set("demoUrl", $("[name=demoUrl]").val())
#    SessionAmplify.set("summary", $("[name=summary]").val())
#    SessionAmplify.set("code", $("[name=code]").val())
#    SessionAmplify.set("export", $("[name=export]").val())
  
  
  MeteorPackage.atmosphereName = $("[name=atmosphereName]").val()
  MeteorPackage.githubName = $("[name=githubName]").val()
  MeteorPackage.packageName = $("input[name=packageName]").val()
  MeteorPackage.demoUrl =
    switch $("[name=demoUrl_type]:checked").val()
      when "meteor" then "http://#{ $("input[name=demoUrl_meteorSubdomain]").val() }.meteor.com/"
      when "custom" then (
        customUrl = $("input[name=demoUrl_customUrl]").val()
        if not customUrl.startsWith "http"
          customUrl = "http://" + customUrl
        return customUrl
      )
      else null
  
  MeteorPackage.summary = $("input[name=summary]").val()
  MeteorPackage.requiredMeteorVersion = $("select[name=requiredMeteorVersion]").val()
  MeteorPackage.code = $("[name=code]").val()
  MeteorPackage.export = $("[name=export]").val()
  # MeteorPackage.npmDeps = parseDeps($("[name=npmDeps]").val())
  
  MeteorPackage.packageType = $("input:checked[name=packageType]").val()
  MeteorPackage.testFramework = $("input:checked[name=testFramework]").val()

updatePackage = _.debounce(_updatePackage, 50)

@KitchenRouteController = RouteController.extend(
  template: "kitchen"

  data: MeteorPackage
)

KitchenRouteController.events(
  "click .savePackage" : updatePackage
  "change input[type=radio]": updatePackage
  "change select": updatePackage
  "keyup input" : updatePackage
  "keyup textarea" : updatePackage
  "keyup #code" : suggestExports
  'click .dependencies .delete': (event, template) ->
    # todo: should be retrieved via @data() - but doesn't work?

#    packageDeps.splice(
#      packageDeps.indexOf (packageDeps.filter (dependency) -> dependency.name is event.currentTarget.dataset.dependencyName)[0]
#      1
#    )
    # doesn't work because it bypasses the setters/getters

    MeteorPackage.meteorPackageDependencies = MeteorPackage.meteorPackageDependencies.filter (dependency) ->
      dependency.name isnt event.currentTarget.dataset.dependencyName

  'submit #add-meteor-package': (event, template) ->
    event.preventDefault()

    packageNameField = template.find('[name=package-name]')

    MeteorPackage.meteorPackageDependencies = MeteorPackage.meteorPackageDependencies.concat(
      name: packageNameField.value
    )

    packageNameField.value = ""
)

KitchenRouteController.helpers(
  isMarkdown: (path) -> path.match(/\.md$/)
)


suggestExports = (e) ->
  if not $("[name=code]").val()
    $("[name=export]").val("")
    return

  $("[name=export]").val(MeteorPackage.exportSuggestion)


Router.route("home", {
  path: "/"
  controller: "KitchenRouteController"
})
