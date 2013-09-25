<!DOCTYPE html>
<html>
<head>
<meta charset=utf-8 />
<title>@page_title@</title>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<link href="skin/blue.monday/jplayer.blue.monday.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.6/jquery.min.js"></script>
<script type="text/javascript" src="js/jquery.jplayer.min.js"></script>
<script type="text/javascript" src="js/jplayer.playlist.min.js"></script>
<script type="text/javascript">
//<![CDATA[
$(document).ready(function(){
	new jPlayerPlaylist({
		jPlayer: "#jquery_jplayer_1",
		cssSelectorAncestor: "#jp_container_1"
	}, [
	    <multiple name="songs" delimiter=",">
	      { mp3:"@songs.song_url@" }
	    </multiple>
	],{
		swfPath: "js",
	   //supplied: "webmv, ogv, m4v, oga, mp3"
		wmode: "window"
	});
});
//]]>
</script>
</head>
<body>
  <p>
    <a href='index' title='Torna alle playlist'>Lista Playlist</a>
  </p>
  <div id="jp_container_1" class="jp-audio">
    <div class="jp-type-playlist">
      <div id="jquery_jplayer_1" class="jp-jplayer"></div>
      <div class="jp-gui">
	<div class="jp-interface">
	  <div class="jp-controls-holder">
	    <ul class="jp-controls">
	      <li><a href="javascript:;" class="jp-play" tabindex="1">play</a></li>
	      <li><a href="javascript:;" class="jp-pause" tabindex="1">pause</a></li>
	    </ul>
	  </div>
	</div>
      </div>
      <div class="jp-playlist">
	<ul><!-- The method Playlist.displayPlaylist() uses this unordered list --></ul>
      </div> 
      <div class="jp-no-solution">
	<span>Update Required</span>
	To play the media you will need to either update your browser to a recent version or update your <a href="http://get.adobe.com/flashplayer/" target="_blank">Flash plugin</a>.
      </div>
    </div>
  </div>
</body>
</html>

