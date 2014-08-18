# mandatory parameters:
# - group_id:integer

# current connection 
# variables we need
set connvars {
  user_id
  package_key
}

foreach connvar $connvars {
  set $connvar [ad_conn $connvar]
}

cmit::group::get \
  -group_id $group_id \
    -array group -locale [lang::conn::browser_locale]
set group_name [string toupper $group(group_name)]
set thumbnail_id  $group(thumbnail_id)
if {$thumbnail_id ne ""} {
    set thumbnail $group(thumbnail_url)
}

set page_title $group_name
set doc(title) $page_title

# All playlists this user has access to
db_multirow -extend {
    name
    description
    n_songs
    songs_url
} playlists query "
  select playlist_id
  from cmit_playlists
  where (valid_from is null or 
         current_date >= valid_from)
    and (valid_to is null or 
         current_date <= valid_to)
    order by order_no asc" {
    # skipp all playlists which are not
    # accessible from this group AND
    # this user.
    if {![permission::permission_p \
	    -party_id  $user_id \
	    -object_id $playlist_id \
	    -privilege "read"] ||
        ![permission::permission_p \
	    -party_id  $group_id \
	    -object_id $playlist_id \
	    -privilege "read"]} {
	continue
    }
    
    cmit::playlist::get -playlist_id $playlist_id -array playlist
    set name        $playlist(name)
    set name        [string toupper $playlist(name)]
    set description $playlist(description)
    
    set songs_url [export_vars -base "play-songs" {playlist_id}]
}

set n_playlists [template::multirow size playlists]