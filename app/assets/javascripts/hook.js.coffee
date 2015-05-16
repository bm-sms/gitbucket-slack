$ ->
  $('.copy').on 'click', (event)->
    event.clipboardData.setData 'text/plain', $('.copyable').text()
    event.preventDefault()
