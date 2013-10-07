<master src="/www/blank-master">
<if @doc@ defined><property name="&doc">doc</property></if>

<img style="display:none;" src="skin/blue.monday/playIcon16x16.png">
<img style="display:none;" src="skin/blue.monday/stillIcon16x16.png">
<img style="display:none;" src="skin/blue.monday/forwardIcon16x16.png">
<img style="display:none;" src="skin/blue.monday/reverseIcon16x16.png">
<img style="display:none;" src="skin/blue.monday/playHoverIcon16x16.png">
<img style="display:none;" src="skin/blue.monday/stillHoverIcon16x16.png">
<img style="display:none;" src="skin/blue.monday/forwardHoverIcon16x16.png">
<img style="display:none;" src="skin/blue.monday/reverseHoverIcon16x16.png">

<img style="display:none;" src="skin/blue.monday/playIcon32x32.png">
<img style="display:none;" src="skin/blue.monday/stillIcon32x32.png">
<img style="display:none;" src="skin/blue.monday/forwardIcon32x32.png">
<img style="display:none;" src="skin/blue.monday/reverseIcon32x32.png">
<img style="display:none;" src="skin/blue.monday/playHoverIcon32x32.png">
<img style="display:none;" src="skin/blue.monday/stillHoverIcon32x32.png">
<img style="display:none;" src="skin/blue.monday/forwardHoverIcon32x32.png">
<img style="display:none;" src="skin/blue.monday/reverseHoverIcon32x32.png">

<script type="text/javascript">
  if (screen.height <= 900) {
 	 document.write("<link href='skin/blue.monday/jplayer.blue.monday.css' rel='stylesheet' type='text/css' </meta>");
  }
  else {
	  document.write("<link href='skin/blue.monday/jplayer.blue.monday.big.css' rel='stylesheet' type='text/css' </meta>");
  }
</script>


<div id="cm_container">
  <div id="log">
    <if @logged_p@ ne 0>
      <a style="color:black;" class="log" href='@logout_url@'>LogOut</a>
    </if>
  </div>
  <div id="cm_groups">
    <div id="title"><img src="images/Logo.png" border="0"></div>
    <multiple name="groups">
      <div class="cm_group">
	<include 
	  src="/packages/@package_key@/lib/playlists-menu"
	  group_id="@groups.group_id@"
	>
      </div>
    </multiple>
    <div id="visible_players"></div>
    <if @logged_p@ eq 0>
      <a id="login" style="color:black;" href='@login_url@'>Login</a>
    </if>
  </div>
  <div id="cm_group_thumbnail">
    <multiple name="groups">
      <img id="thumnail_@groups.group_id@" src="@groups.thumbnail_url@" alt="Nessuna immagine per il gruppo selezionato" width="700" border="0">
    </multiple>
  </div>
</div>
