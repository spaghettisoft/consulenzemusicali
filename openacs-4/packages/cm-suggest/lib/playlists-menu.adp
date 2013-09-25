<div class="cm_group_name" group_id="@group_id@">
  @group_name@
</div>
<div class="cm_playlist_players">
  <multiple name="playlists">
  <div>
    <div class="cm-playlist-player">
      <include 
	src="/packages/@package_key@/lib/playlist-player"
	playlist_id="@playlists.playlist_id@"
	group_id="@group_id@"
      >
    </div>
    <div class="cm-playlist-name">@playlists.name@</div>
  </div>
  </multiple>
</div>
