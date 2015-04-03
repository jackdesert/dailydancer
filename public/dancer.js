$(document).ready(function(){

  toggleVisibilityOnFastClick()
  bindShowMoreButton()
})

var bindShowMoreButton = function(){
  var $showMoreButton = $('.toggle-additional-dates')

  var showLessDays = function(){
    var $more = $('#more')

    if (!$showMoreButton.hasClass('show')){
      // Note that the html in $more remains after slideUp()
      // which is fine because it will be overwritten if showMoreDays() is called
      // Note that jQuery animation slideUp is used here because
      // it has a gentler ending for very tall divs than gravity().
      $showMoreButton.toggleClass('working')
      $more.slideUp(1000, function(){
        $showMoreButton.toggleClass('working')
        $showMoreButton.toggleClass('show')
      })
    }else{
      $showMoreButton.toggleClass('show')
    }

  }

  $showMoreButton.on('click', function(){
    var url = '/?xhr=true'
    var that = this
    var $more = $('#more')

    var showMoreDays = function(data, status){
      $(that).unbind() // Because we need to bind the new showMoreButton
      $more.html(data)
      gravity($more, 'down')

      // Give gravity a head start before toggling 'working' class
      setTimeout(function(){
        $(that).toggleClass('working')
      }, 200)
      bindShowMoreButton()

      showLessDays()
    }

    if ($(this).hasClass('working')){
      // Do not make additional xhr requests if one is already in progress
      return
    }

    if ($(this).hasClass('show')){
      $(that).toggleClass('working')
      $.get(url, showMoreDays)
    }else{
      showLessDays()
    }
  })
}

var toggleVisibilityOnFastClick = function(){

  var squaredResolution = 16
  var lastX = 0
  var lastY = 0

  $('#content').on('mousedown', '.message-or-event', function(event){
    lastX = event.pageX
    lastY = event.pageY
  })

  $('#content').on('mouseup', '.message-or-event', function(event){
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

  var acceleration = 2
  var time = 0
  var that = this
  var speedConstant = $('body')[0].offsetWidth / 10000
  var practicalInfinity = 1000000
  var startHeight, callback, directionConstant, isFinished, newMaxHeight

  var initialize = function(){
    if (direction === 'down'){
      startHeight = 0
      destinationHeight = 2000
      directionConstant = 1
      isFinished = function(){ return (newMaxHeight > destinationHeight) }
      callback = function(){ $target.css('max-height', practicalInfinity) }

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
    newMaxHeight = startHeight + 0.5 * speedConstant * directionConstant * acceleration * time * time

    //console.log('newMaxHeight', newMaxHeight)
    //console.log('destinationHeight', destinationHeight)
    //console.log('isFinished', isFinished())

    // Call this again and again until isFinished() comes back true
    if (isFinished()){
      // Make sure the callback is the last thing called
      setTimeout(callback, deltaTime)
      console.log('You are Awesome!')
    }else{
      setTimeout(dropALittle, deltaTime)
    }

    $target.css('max-height', newMaxHeight)
  }

  initialize()
  dropALittle()
}

