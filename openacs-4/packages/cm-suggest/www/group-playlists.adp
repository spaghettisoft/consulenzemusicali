<master src="/www/blank-master">
<if @doc@ defined><property name="&doc">doc</property></if>

<style type="text/css">
  body {
    font-family:Arial, sans-serif;
    color:black;
  }
  #cm_group_container {
      margin-left:15%;
      margin-right:15%;
      position:relative;
      top:2cm;
  }
  #cm_group_thumbnail {
      float:left;
      width:754px;
      margin-left: 30px;
  }
  #cm_group_name {
      font-size: 12pt;
      color:black;
      text-decoration:none;
      font-weight:bold;
  }
  #cm_playlists_menubar {
      float:left;
      width:129px;
  }
  .cm-playlist-player {
      float:left;
      width:20px;
      height:16px;
  }
  .cm-playlist-name {
      float:left;
      width:100px;
      margin-left:5px;
      font-size: 9pt;
  }
</style>
<script type="text/javascript">
  $(function() { 
      var content = $('#cm_group_thumbnail');
      var images = content.find('img');
      
      images.hide();
      
      var stillDuration = 3000;
      var fadeDuration = 600;
      var totDuration = stillDuration + (fadeDuration * 2);
      
      function animateImages (index) {
	  var nextIndex = index + 1;
	  if (nextIndex >= images.length) {
	      nextIndex = 0;
	  }
	  content.find('> :eq(' + index + ')').fadeIn(fadeDuration).delay(stillDuration).fadeOut(fadeDuration, function () { animateImages(nextIndex) });
      }
      
      animateImages(0);
  });
</script>
<div id="cm_group_container">
  <multiple name="groups">
    <include 
      src="/packages/@package_key@/lib/playlists-menu"
      playlist_id="@groups.group_id@"
    >
  </multiple>
  <div id="cm_group_thumbnail">
    <list name="thumbnails">
      <img src="@thumbnails:item@" alt="Nessuna immagine per la playlist selezionata" width="754" border="0">
    </list>
  </div>
</div>
