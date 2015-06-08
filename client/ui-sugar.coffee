Template.kitchen.onRendered ->
  background = document.getElementById 'background'
  $(document).on 'scroll', (event) ->
    background.style.top = "-#{ event.originalEvent.pageY / 20 }px"