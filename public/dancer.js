
$(document).ready(function(){

  toggleMessageOnFastClick()

})


var toggleMessageOnFastClick = function(){

  var fastClickTime = 200
  var lastMouseDown = Date.now()

  $('.message').mousedown(function(event){
    lastMouseDown = Date.now()
  })

  $('.message').mouseup(function(event){
    var elapsedTime = Date.now() - lastMouseDown

    // console.log(event.target.nodeName)

    // Only toggle if they are NOT clicking on a link
    // AND if the mousedown was very recent (indicating no text selection)
    if (event.target.nodeName !== 'A' && elapsedTime < fastClickTime ){
      $(this).children('.details').toggleClass('hidden')
    }

  })
}

