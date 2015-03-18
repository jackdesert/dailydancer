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
    var expandedClass = 'expanded'
    var $details = $(this).children('.details')

    // Only toggle if they are NOT clicking on a link
    // AND if the mousedown was very recent (indicating no text selection)
    if (event.target.nodeName !== 'A' && deltaSquared < squaredResolution ){

      // Check for expandedClass before toggle in case of race condition
      if ($details.hasClass(expandedClass)){
        gravity($details, 'up')
      }else{
        gravity($details, 'down')
      }

      $details.toggleClass('expanded')
    }

  })
}


var gravity = function($target, direction){

  var acc = 0.1  //acceleration
  var time = 0
  var that = this
  var startHeight, callback, directionConstant, isFinished, newMaxHeight

  var initialize = function(){
    if (direction === 'down'){
      startHeight = 0
      destinationHeight = 1000
      directionConstant = 1
      isFinished = function(){ return (newMaxHeight > destinationHeight) }
      callback = function(){ $target.css('max-height', 10000000) }

      $target.css('max-height', 0)
      $target.show()
    }else if (direction === 'up'){
      startHeight = $target[0].offsetHeight
      destinationHeight = 0
      directionConstant = -1
      isFinished = function(){ return (newMaxHeight < destinationHeight) }
      callback = function(){ $target.hide() }
    }else{
      console.log('Direction must be up or down')
    }
  }

  var dropALittle = function(){
    var deltaTime = 3 // How long to wait between refreshes
    time += deltaTime
    newMaxHeight = startHeight + 0.5 * directionConstant * acc * time * time
    console.log('newMaxHeight', newMaxHeight)
    console.log('destinationHeight', destinationHeight)
    console.log('isFinished', isFinished())

    // Call this again and again until isFinished() comes back true
    if (isFinished()){
      callback()
    }else{
      setTimeout(dropALittle, deltaTime)
    }

    console.log(newMaxHeight)
    $target.css('max-height', newMaxHeight)
  }

  initialize()
  dropALittle()
}

