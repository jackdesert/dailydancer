
$(document).ready(function(){

  toggleMessageOnFastClick()

})


var toggleMessageOnFastClick = function(){


  var squaredResolution = 16
  var lastX = 0
  var lastY = 0

  $('.message').mousedown(function(event){
    lastX = event.pageX
    lastY = event.pageY
  })

  $('.message').mouseup(function(event){
    var deltaX = event.pageX - lastX
    var deltaY = event.pageY - lastY
    var deltaSquared = deltaX * deltaX + deltaY * deltaY

    // console.log(event.target.nodeName)

    // Only toggle if they are NOT clicking on a link
    // AND if the mousedown was very recent (indicating no text selection)
    if (event.target.nodeName !== 'A' && deltaSquared < squaredResolution ){
      $(this).children('.details').toggleClass('hidden')
    }

  })
}

