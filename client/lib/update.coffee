_updatePackage = ->
  parseDeps = (depsString) ->
    if depsString is ""
      return []

    return depsString.split(/\s*,\s*/)

  kitchenPackage = Router.current().data().kitchenPackage

  kitchenPackage.atmosphereName = $("[name=atmosphereName]").val()
  kitchenPackage.githubName = $("[name=githubName]").val()
  kitchenPackage.packageName = $("input[name=packageName]").val()
  kitchenPackage.demoUrl =
    switch $("[name=demoUrl_type]:checked").val()
      when "meteor" then "http://#{ $("input[name=demoUrl_meteorSubdomain]").val() }.meteor.com/"
      when "custom" then (
        customUrl = $("input[name=demoUrl_customUrl]").val()
        if not customUrl.startsWith "http"
          customUrl = "http://" + customUrl
        return customUrl
      )
      else null

  kitchenPackage.transpiler =
    switch $("[name=dialect]:checked").val()
      when "ecma6" then PackageKitchen.TRANSPILERS.ECMA6
      when "coffeescript" then PackageKitchen.TRANSPILERS.COFFEESCRIPT
      else PackageKitchen.TRANSPILERS.NONE

  kitchenPackage.summary = $("input[name=summary]").val()
  kitchenPackage.requiredMeteorVersion = $("select[name=requiredMeteorVersion]").val()
  kitchenPackage.code = $("[name=code]").val()

  exportValue = $("[name=exports]").val()
  if exportValue? and exportValue.trim().length isnt 0
    kitchenPackage.exports = [ $("[name=exports]").val() ]
  else
    kitchenPackage.exports = []

  # MeteorPackage.npmDeps = parseDeps($("[name=npmDeps]").val())

  kitchenPackage.scope = $("input:checked[name=scope]").val()
  kitchenPackage.testFramework =
    switch $("[name=testFramework]:checked").val()
      when 'tinytest' then PackageKitchen.TESTING_FRAMEWORKS.TINYTEST
      when 'mocha' then PackageKitchen.TESTING_FRAMEWORKS.MOCHA
      when 'munit' then PackageKitchen.TESTING_FRAMEWORKS.MUNIT
      else PackageKitchen.TESTING_FRAMEWORKS.NONE

  kitchenPackage.useTravis = $('#travis').is(':checked')

share.updatePackage = _.debounce(_updatePackage, 50)