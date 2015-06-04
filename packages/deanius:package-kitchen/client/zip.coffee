zipPackage = ->
  zip = new JSZip()

  MeteorPackage.allFilesRendered.forEach((file) ->
    zip.file(file.path, file.contents);
  )

  window.location = "data:application/zip;base64," + zip.generate(type: "base64")

