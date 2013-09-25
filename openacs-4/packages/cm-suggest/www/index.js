$(function() {
    
    // ##Fade effect looping on group thumbnails##
    
    var content = $('#cm_group_thumbnail');
    var images = content.find('img');
    
    // Animate only if we have more than 1 image
    if (images.length > 1) {
      images.hide();
      
      var stillDuration = 3000;
      var fadeDuration = 800;
      var flag_keep_going = true;
      
      function animateImages (index) {
	  if (!flag_keep_going)
	    return;
	  var nextIndex = index + 1;
	  if (nextIndex >= images.length) {
	      nextIndex = 0;
	  }
	  content.find('> :eq(' + index + ')')
	    .fadeIn(fadeDuration)
	      .delay(stillDuration)
		.fadeOut(fadeDuration, function () { 
		    animateImages(nextIndex) 
		});
      }
      
      animateImages(0);
    }
    
    // ##**##
    
    
    // ##Dropdown effect on playlist menus##
    
    var players = $('.cm_playlist_players');
    players.hide();
    
    var visiblePlayersContainer = $('#visible_players');
    
    function showPlayers(myPlayers, hisPlayers) {
      var newOwner = myPlayers.parent();
      if (!newOwner.is('#cm_selected')) {
	var prevOwner = $('#cm_selected');
	prevOwner.removeAttr('id');
	newOwner.attr('id', 'cm_selected');
	if (prevOwner.length > 0) {
	  prevOwner.append(hisPlayers);
	}
      
	visiblePlayersContainer.append(myPlayers);
	myPlayers.slideDown('slow');
      }
    }
    
    // ##**##
    
    $('.cm_group_name').click(function () {
      
      // Stop recurring of animations
      flag_keep_going = false;
      
      // Stop animations running and to be run on all thumbnails
      var thumbnails = $('#cm_group_thumbnail > img');
      thumbnails.clearQueue();
      thumbnails.hide();
      
      // Show selected thumbnail
      $('#thumnail_' + $(this).attr('group_id')).show();

      var myPlayers = $(this).siblings('.cm_playlist_players');
      var visiblePlayers = visiblePlayersContainer.children();
      if (visiblePlayers.size() > 0) {
	  visiblePlayers.slideUp('slow', function () {
	      showPlayers(myPlayers, visiblePlayers);
	  });
      } else {
	  showPlayers(myPlayers);
      }
      
    });
    
});