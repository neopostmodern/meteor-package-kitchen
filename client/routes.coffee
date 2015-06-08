kitchenPackage = PackageKitchen.GetPackage()

@KitchenRouteController = RouteController.extend(
  template: "kitchen"

  data: ->
    kitchenPackage: kitchenPackage # PackageKitchen.GetPackage()
)

KitchenRouteController.events(
  "click .savePackage" : share.updatePackage
  "change input[type=radio]": share.updatePackage
  "change select": share.updatePackage
  "change input[type=checkbox]": share.updatePackage
  "keyup input" : share.updatePackage
  "keyup textarea" : share.updatePackage
  "keyup #code" : suggestExports
  'click .dependencies .delete': (event, template) ->
    # todo: should be retrieved via @data() - but doesn't work?

#    packageDeps.splice(
#      packageDeps.indexOf (packageDeps.filter (dependency) -> dependency.name is event.currentTarget.dataset.dependencyName)[0]
#      1
#    )
    # doesn't work because it bypasses the setters/getters

    kitchenPackage = Router.current().data().kitchenPackage

    kitchenPackage.meteorPackageDependencies = kitchenPackage.meteorPackageDependencies.filter (dependency) ->
      dependency.name isnt event.currentTarget.dataset.dependencyName

  'submit #add-meteor-package': (event, template) ->
    event.preventDefault()

    kitchenPackage = Router.current().data().kitchenPackage

    packageNameField = template.find('[name=package-name]')

    kitchenPackage.meteorPackageDependencies = kitchenPackage.meteorPackageDependencies.concat(
      name: packageNameField.value
    )

    packageNameField.value = ""
)

KitchenRouteController.helpers(
  isMarkdown: (path) -> path.match(/\.md$/)
)


suggestExports = (e) ->
  if not $("[name=code]").val()
    $("[name=exports]").val("")
    return

  $("[name=exports]").val(PackageKitchen.exportSuggestion)


Router.route("home", {
  path: "/"
  controller: "KitchenRouteController"
})
