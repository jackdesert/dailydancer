$(document).ready(function(){
  $('.message').click(function(event){
    console.log(event.target.nodeName)


    if (event.target.nodeName !== 'A'){
      // Only toggle if they are NOT clicking on a link
      $(this).children('.details').toggleClass('hidden')
    }

  })
})

