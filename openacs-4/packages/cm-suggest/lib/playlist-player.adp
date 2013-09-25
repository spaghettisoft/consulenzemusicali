<script type="text/javascript">
//<![CDATA[
$(function() { 
    new jPlayerPlaylist({
	    jPlayer: "#jquery_jplayer_@playlist_dom_id@",
	    cssSelectorAncestor: "#jp_container_@playlist_dom_id@"
    }, [
	<multiple name="songs" delimiter=",">
	  { mp3:"@songs.song_url@" }
	</multiple>
    ],{
	playlistOptions: {
	  loopOnPrevious: true
	},
	preload: "none",
	swfPath: "js",
	loop:true,
	//supplied: "webmv, ogv, m4v, oga, mp3"
	wmode: "window"
    });
});
//]]>
</script>
<div id="jp_container_@playlist_dom_id@" class="jp-audio">
  <div class="jp-type-playlist">
    <div id="jquery_jplayer_@playlist_dom_id@" class="jp-jplayer"></div>
    <div class="jp-gui">
      <div class="jp-interface">
	<div class="jp-controls-holder">
	  <ul class="jp-controls">
	    <if @show_all_buttons_p@>
<!-- 	      <li><a href="javascript:;" class="jp-previous" tabindex="1">previous</a></li> -->
	    </if>
	    <li><a href="javascript:;" class="jp-play" tabindex="1">play</a></li>
	    <li><a href="javascript:;" class="jp-pause" tabindex="1">pause</a></li>
	    <if @show_all_buttons_p@>
	      <li><a href="javascript:;" class="jp-next" tabindex="1">next</a></li>
	    </if>
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