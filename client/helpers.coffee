#Template.kitchen.events({
#//todo:  "click .download" : zipPackage,
#  "click .saveToApp" : function (e) {
#    Meteor.promise(
#      "deanius:package-kitchen#saveToApp",
#      packageModel.fullPackageName, packageModel.allFilesRendered
#    ).then(
#      function(){ alert("Your package has been created. App will now reload.") },
#      function(err){ alert(err.reason); }
#    );
#  }
#});
#Template.description.onRendered(function () {
#  $("[name=atmosphereName]").val(SessionAmplify.get("atmosphereName"));
#  $("[name=githubName]").val(SessionAmplify.get("githubName"));
#  $("[name=packageName]").val(SessionAmplify.get("packageName"));
#  $("[name=summary]").val(SessionAmplify.get("summary"));
#  $("[name=demoUrl]").val(SessionAmplify.get("demoUrl"));
#  $("[name=code]").val(SessionAmplify.get("code") || packageModel.code);
#  $("[name=export]").val(SessionAmplify.get("export") || packageModel.export);
#
#  _updatePackage();
#});

UI.registerHelper "materialClassHelper",
  (property) -> if property? and property.length then "active" else ""

Template.dependencies.rendered = ->
  @findAll('select')
    .forEach (select) ->
      $(select).material_select()
