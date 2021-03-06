<master src="/www/blank-master">
<if @doc@ defined><property name="&doc">doc</property></if>

<!--
Not needed, we now have a unique vectorial sprite for every button :-)
<img style="display:none;" src="skin/blue.monday/playForwardStillSprite16x16.png">
<img style="display:none;" src="skin/blue.monday/playIcon16x16.png">
<img style="display:none;" src="skin/blue.monday/stillIcon16x16.png">
<img style="display:none;" src="skin/blue.monday/forwardIcon16x16.png">
<img style="display:none;" src="skin/blue.monday/reverseIcon16x16.png">
<img style="display:none;" src="skin/blue.monday/playHoverIcon16x16.png">
<img style="display:none;" src="skin/blue.monday/stillHoverIcon16x16.png">
<img style="display:none;" src="skin/blue.monday/forwardHoverIcon16x16.png">
<img style="display:none;" src="skin/blue.monday/reverseHoverIcon16x16.png">

<img style="display:none;" src="skin/blue.monday/playForwardStillSprite32x32.png">
<img style="display:none;" src="skin/blue.monday/playIcon32x32.png">
<img style="display:none;" src="skin/blue.monday/stillIcon32x32.png">
<img style="display:none;" src="skin/blue.monday/forwardIcon32x32.png">
<img style="display:none;" src="skin/blue.monday/reverseIcon32x32.png">
<img style="display:none;" src="skin/blue.monday/playHoverIcon32x32.png">
<img style="display:none;" src="skin/blue.monday/stillHoverIcon32x32.png">
<img style="display:none;" src="skin/blue.monday/forwardHoverIcon32x32.png">
<img style="display:none;" src="skin/blue.monday/reverseHoverIcon32x32.png">
-->

<script type="text/javascript">
  if (screen.width >= 800) {
      document.write("<link href='css/style.css' rel='stylesheet' type='text/css' </meta>");
      document.write("<link href='skin/blue.monday/jplayer.blue.monday.css' rel='stylesheet' type='text/css' </meta>");
  }
  else {
      document.write("<link href='css/style.big.css' rel='stylesheet' type='text/css' </meta>");
      document.write("<link href='skin/blue.monday/jplayer.blue.monday.big.css' rel='stylesheet' type='text/css' </meta>");
  }
</script>

<div id="cm_container">
  <div id="cm_groups">
    <div id="title"><img src="images/Logo.svg" width="145" border="0"></div>
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
      <a id="login" style="color:black;" href='@login_url@'>LOGIN</a>
    </if>
  </div>
  <div id="cm_group_thumbnail">
    <multiple name="groups">
      <img id="thumnail_@groups.group_id@" src="@groups.thumbnail_url@" alt="Nessuna immagine per il gruppo selezionato" width="700" border="0">
    </multiple>
  </div>
</div>
<footer id="log">
  <if @logged_p@ ne 0>
  <span style="float:right;"> 
   AREA LEGALE | SERVIZIO CLIENTI | CONTATTI | ENGLISH | <a style="color:inherit; text-decoration:none;" href='@logout_url@'>LOGOUT</a>
  </span>
  </if>
</footer>


<!-- New Safari seems to handle animations correctly -->
<!-- <script type="text/javascript">
//   $(function() {
    // This is to force clicked buttons to get out 
    // of the way before the one is coming arrives.
    // Required for Safari in Ipad, otherwise, for a short
    // istant there will be 2 elements making buttons overflow.
//     $('.jp-pause, .jp-play').click(function () {
//       $(this).hide();
//       $('.jp-pause').hide();
//     });
  });
</script> -->
