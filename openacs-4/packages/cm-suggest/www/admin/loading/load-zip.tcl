ad_page_contract {

  @author Antonio Pisano

} {
    {mode "edit"}
}

set page_title "Caricamento Playlist da file ZIP"
set buttons [list [list "Carica" new]]


set locale [ad_conn locale]


# Obtain groups selectable by checkbox
set group_options [list]
foreach group_id [db_list query "select group_id from cmit_groups"] {
  cmit::group::get -group_id $group_id -array group
  lappend group_options [list $group_id $group_name]
}


set form {
    {zip_file:file(file)
	{label "ZIP Playlist"}
	{help_text {L'archivio deve contenere almeno un brano e al massimo una thumbnail}}
    }
    {groups:text(checkbox),multiple,optional
	{label {Assegnare la playlist ai gruppi...}}
	{options $group_options}
    }
    {valid_from:date,optional
	{label {Valida dal}}
    }
    {valid_to:date,optional
	{label {Valida al}}
    }
    {overwrite_playlists_p:text(radio),optional
	{options {{"Si" t} {"No" f}}}
	{value f}
	{label {Sovrascrivere playlist esistenti?}}
    }
    {overwrite_songs_p:text(radio),optional
	{options {{"Si" t} {"No" f}}}
	{value f}
	{label {Sovrascrivere brani esistenti?}}
    }
}

ad_form -html { enctype multipart/form-data } -name addedit \
    -mode $mode \
    -edit_buttons $buttons \
    -has_edit 1 \
    -form $form \
 -on_request {
    

} -on_submit {
    
    set valid_from_ansi [join [lrange $valid_from 0 2] -]
    set valid_to_ansi   [join [lrange $valid_to   0 2] -]
    
    util_unlist $zip_file filename file.tmpfile mime_type
    
    # Playlist's name is the name of the file, minus its extension
    util_unlist [split $filename .] playlist_name extension
    
    if {$mime_type ne "application/zip" || $extension ne "zip"} {
	template::form::set_error addedit zip_file "Il formato del file inviato non è supportato."
	break
    }
    
    set playlist_name       [string trim    $playlist_name]
    set playlist_name_upper [string toupper $playlist_name]
    
    # Get names for existing playlists
    foreach playlist_id [db_list query "select playlist_id from cmit_playlists"] {
      cmit::playlist::get -playlist_id $playlist_id -locale $locale -array playlist
      set playlists([string toupper $playlist(name)]) $playlist_id
    }
    
    # Check if playsists already exists...
    set existing_playlist_p [info exists playlists($playlist_name_upper)]
    if {$existing_playlist_p && !$overwrite_playlists_p} {
	template::form::set_error addedit zip_file "Playlist '$playlist_name' già esistente."
	break
    }
    
    # Create a temporary directory to store unzipped files
    set tmpdir [ns_tmpnam]
    ns_mkdir $tmpdir
    
    # Unzip files in directory
    exec "unzip ${file.tmpfile} -d $tmpdir"
    
    # All files in zip archive
    set zip_files [glob -nocomplain -directory $tmpdir *]
    
    if {$zip_files eq ""} {
	template::form::set_error addedit zip_file "Nessun file contenuto nell'archivio."
    }
    set thumbnail ""
    foreach zipfile $zip_files {
	# Get mime_type for each file in zip
	set mime_type [string trim [exec "file --mime-type -b \"$tmpdir/$zipfile\""]]
	if {![regexp ^audio/.* $mime_type] && ![regexp ^image/.* $mime_type]} {
	    template::form::set_error addedit zip_file "L'archivio contiene file non supportati."
	    file delete -force -- $tmpdir
	    break
	}
	# Separate thumbnail from song files
	if {[regexp ^image/.* $mime_type]} {
	    lappend thumbnail $zipfile
	} else {
	    lappend songs $zipfile
	}
	# Only one thumbnail is allowed
	if {[llength thumbnail] > 1} {
	    template::form::set_error addedit zip_file "L'archivio contiene più di una thumbnail."
	    file delete -force -- $tmpdir
	    break
	}
    }
    
    if {$songs eq ""} {
	template::form::set_error addedit zip_file "Nessun brano contenuto nell'archivio."
	file delete -force -- $tmpdir
	break
    }
    
    # Get existing songs
    foreach song_id [db_list query "select song_id from cmit_songs"] {
      cmit::song::get -song_id $song_id -array song
      set song_name "$song(author) $song(title)"
      set songs([string toupper $song_name]) $song_id
    }
    
    foreach song $songs {
	# Name of the song without extension
	set song_filename [lindex [split $song .] 0]
	util_unlist [split $song_filename -] order_no author title
	set order_no [string trim $order_no]
	set author [string trim $author]
	set title  [string trim $title]
	  
	if {![string is integer $order_no]} {
	    template::form::set_error addedit zip_file "'$song_filename' non contiene un ordine valido per il brano."
	    file delete -force -- $tmpdir
	    break
	}
	set song_name [string toupper "$author $title"]
	set existing_song_p [info exists songs($song_name)]
	if {$existing_song_p && !$overwrite_songs_p} {
	    template::form::set_error addedit zip_file "Brano '$song_name' già esistente."
	    file delete -force -- $tmpdir
	    break
	}
    }
    
    
    # Everything ok, from here we start loading
    db_transaction {
	
	# If playlist exists and we got here, it means we overwrite it...
	if {[info exists playlists($playlist_name_upper)]} {
	    set playlist_id $playlists($playlist_name_upper)
	    # ...so it will be emptied...
    	    foreach song_id [cmit::playlist::get_songs -playlist_id $playlist_id] {
		cmit::playlist::delete_song -playlist_id $playlist_id -song_id $song_id
	    }
	    # ...and then modified.
	    cmit::playlist::edit -playlist_id $playlist_id \
		-name                   $playlist_name \
		-thumbnail_filename     $thumbnail \
	        -thumbnail_tmp_filename "$tmpdir/$thumbnail" \
		-valid_from             $valid_from
		-valid_to               $valid_to \
		-locale                 $locale
	    	
	# ...otherwise it will be created anew
	} else {
	    set playlist_id [cmit::playlist::add \
		-name                   $playlist_name \
	        -thumbnail_tmp_filename "$tmpdir/$thumbnail" \
		-thumbnail_filename     $thumbnail \
		-valid_from             $valid_from
		-valid_to               $valid_to \
		-locale                 $locale]
	}
	
	# Grant permissions for groups specified
	foreach group_id $groups {
	  permission::grant -party_id $group_id -object_id $playlist_id -privilege read
	}
	
	set subsite_group_id [cmit::group::get_subsite_group_id]
	
	foreach song $songs {
	    # Name of the song without extension
	    set song_filename [lindex [split $song .] 0]
	    util_unlist [split $song_filename -] order_no author title
	    set order_no [string trim $order_no]
	    set author   [string trim $author]
	    set title    [string trim $title]
	    
	    set song_name [string toupper "$author $title"]
	    # If song exists, we will overrite it...
	    if {[info exists songs($song_name)]} {
		set song_id $songs($song_name)
		# ...so we take note of each playlist containing it...
		set playlists [db_list_of_lists query "
		  select playlist_id, order_no 
		    from cmit_playlist_songs
		where song_id = :song_id"]
		# ...then we delete it.
		cmit::song::delete -song_id $song_id
	    }
	    # Otherwise the only playlist for the song will be this.
	    lappend playlists [list $playlist_id $order_no]
	    
	    set song_id [cmit::song::add \
		-author       $author \
		-title        $title \
		-filename     $song \
		-tmp_filename "$tmpdir/$song"]
	    # Single songs will be readable by every user of the subsite
	    permission::grant -party_id $subsite_group_id -object_id $song_id -privilege read
	    
	    set this_playlist_id $playlist_id
	    foreach playlist [lsort -index 1 -increasing $playlists] {
		util_unlist $playlist playlist_id order_no
		cmit::playlist::add_song -playlist_id $playlist_id -song_id $song_id
		# Add api doesn't allow setting the order. This is ok for 'our' new
		# playlist, which is filled top to bottom as the api does.
		# For other playlists we restore previous ordering of the song.
		if {$playlist_id != $this_playlist_id} {
		    db_dml query "
		      update cmit_playlist_songs set 
			  order_no = :order_no
			where playlist_id = :playlist_id
			  and song_id     = :song_id"
		}
	    }
	}
	
	# That's it folks!
    }
    

} -after_submit {
    ad_script_abort
}
