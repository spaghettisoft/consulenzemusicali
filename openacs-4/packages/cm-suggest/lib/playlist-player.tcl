# mandatory parameters:
# - playlist_id:integer

# optional parameters:
# - group_id:integer

set show_all_buttons_p t

# current connection 
# variables we need
set connvars {
  user_id
  locale
}

# parameters we need
set params {
  jquery_path 
  jplayer_path 
  jplayer_skin_path 
  jplayer_playlist_path
}

foreach connvar $connvars {
  set $connvar [ad_conn $connvar]
}

foreach param $params {
  if {[set $param [parameter::get -parameter $param -default ""]] eq ""} {
    ad_complain "Parametro $param non impostato." ; return
  }
}

# add jplayer skin css to the page header
template::head::add_css -href $jplayer_skin_path

# load this java libraries
# in respective orders
set order 0
foreach lib {
  jquery_path 
  jplayer_path 
  jplayer_playlist_path
} {
  template::head::add_javascript -src [set $lib] -order $order
  incr order
}


# The simple playlist_id could not be 
# unique, because we could have the 
# same playlist into different groups.
# If this is the case, I prepend group_id.
if {[exists_and_not_null group_id]} {
  set playlist_dom_id "${group_id}_"
}
append playlist_dom_id $playlist_id

set playlist_name [category::get_name $playlist_id $locale]


# All songs in this playlist this user has access to
db_multirow -extend {
    title
    author
    song_url
} songs query "
  select ps.song_id
  from cmit_playlist_songs ps,
       cmit_songs s
  where ps.playlist_id = :playlist_id
    and ps.song_id     = s.song_id
    and (s.valid_from is null or 
         current_date >= s.valid_from)
    and (s.valid_to is null or 
         current_date <= s.valid_to)
    and (ps.valid_from is null or 
         current_date >= ps.valid_from)
    and (ps.valid_to is null or 
         current_date <= ps.valid_to)
    -- and acs_permission__permission_p(s.song_id,:user_id,'read')
  order by ps.order_no asc" {
    # skipp all songs this user has not access to
    if {![permission::permission_p \
	    -party_id  $user_id \
	    -object_id $song_id \
	    -privilege "read"]} {
	continue
    }
    
    cmit::song::get -song_id $song_id -array song
    set title    $song(title)
    set author   $song(author)
    # JPlayer on Chrome refuses to play the same song
    # in different instances of the player because (as it
    # seems) it locks the file it is using. To prevent this
    # I append a unique key to the URL, making the audios
    # being treated as different files.
    set song_url $song(url)?key=$playlist_dom_id
}