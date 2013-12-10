ad_page_contract {

  @author Antonio Pisano

} {
    {mode "edit"}
}

set page_title "Caricamento Playlist da file ZIP"
set buttons [list [list "Carica" new]]

set context [list [list list {Elenco Playlist}] $page_title]

set locale [ad_conn locale]


# Obtain groups selectable by checkbox
set group_options [list]
foreach group_id [db_list query "select group_id from cmit_groups"] {
  cmit::group::get -group_id $group_id -array group
  set group_name $group(group_name)
  lappend group_options [list $group_name $group_id]
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
    
    with_catch errmsg {
	
	set valid_from [join [lrange $valid_from 0 2] -]
	set valid_to   [join [lrange $valid_to   0 2] -]
	
	util_unlist $zip_file filename file.tmpfile mime_type
	
	# Playlist's name is the name of the file, minus its extension
	set filename_tokens [split $filename .]
	# I take everything in the filename up to the last dot...
	set playlist_tokens [join [lrange $filename_tokens 0 end-1] .]
	# ...replace every underscore with spaces...
	regsub -all {_} $playlist_tokens { } playlist_tokens
	# ...then split by the minus sign to separate playlist name from description.
	set playlist_tokens [split $playlist_tokens -]

	# Playlist names could sometimes contain a '-', so to allow that I
	# consider as separator only the last '-' sign.
	set playlist_name        [string trim [lindex $playlist_tokens 0]]
	set playlist_description [string trim [join [lrange $playlist_tokens 1 end] -]]
	set extension            [string tolower [string trim [lindex $filename_tokens end]]]

	# Different people upload different mime_types... until it is not critical, just do a lazy check of the format.
	# In future, check mime_type in on of "application/zip", "application/x-zip-compressed" (what else??)...
	if {$extension ne "zip"} {
	    error "Il formato del file inviato non è supportato."
	}
	
	set playlist_name_upper [string toupper $playlist_name]
	
	# Get names for existing playlists
	foreach playlist_id [db_list query "select playlist_id from cmit_playlists"] {
	  cmit::playlist::get -playlist_id $playlist_id -locale $locale -array plst
	  set plsts([string toupper $plst(name)]) $playlist_id
	}
	
	# Check if playlist already exists...
	set existing_playlist_p [info exists plsts($playlist_name_upper)]
	if {$existing_playlist_p && !$overwrite_playlists_p} {
	    error "Playlist '$playlist_name' già esistente."
	}
	
	# Create a temporary directory to store unzipped files
	set tmpdir [ns_tmpnam]
	ns_mkdir $tmpdir
	
	# Unzip files in directory
	exec /usr/bin/unzip ${file.tmpfile} -d $tmpdir
	
	# All files in zip archive
	set zip_files [glob -nocomplain -tails -directory $tmpdir *]
	
	if {$zip_files eq ""} {
	    error "Nessun file contenuto nell'archivio."
	}
	set thumbnail ""
	set allowed_song_formats { mp3 }
	set allowed_pics_formats { jpg jpeg png gif }
	foreach zipfile $zip_files {
	# This would be extra safe, but unfortunately calling too much execs is dangerous
	# in tcl, as it can suffer memory leaks... I switch to a 'lazy' check for file format.
	# (After upgrade to Naviserver/OpenAcs5.8, memory problems are solved, but we stick to a lazy check anyway...)
	#	# Get mime_type for each file in zip
	#	set mime_type [string trim [exec file --mime-type -b $tmpdir/$zipfile]]

	    set extension [string tolower [lindex [split $zipfile .] end]]

	    #	if {!($extension eq "mp3" && $mime_type eq "application/octet-stream") && 
	    #	    ![regexp ^audio/.* $mime_type] && ![regexp ^image/.* $mime_type]} {
	    #	    error "L'archivio contiene file non supportati."
	    #	}
	    #	# Separate thumbnail from song files
	    #	if {[regexp ^image/.* $mime_type]} {
	    #	    lappend thumbnail $zipfile
	    #	} else {
	    #	    lappend songs $zipfile
	    #	}

	    if {$extension in $allowed_song_formats} {
		lappend songs $zipfile
	    } elseif {$extension in $allowed_pics_formats} {
		if {$thumbnail eq ""} {
		    set thumbnail $zipfile
		} else {
		    lappend errors "thumbnail '$thumbnail' già presente, '$zipfile' ignorato"
		}
	    } else {
		lappend errors "'$extension' del file '$zipfile' non è un'estensione supportata"
	    }
	}
	
	if {![info exists songs]} {
	    error "Nessun brano valido contenuto nell'archivio."
	}
	
	# Get existing songs
	foreach song_id [db_list query "select song_id from cmit_songs"] {
	  cmit::song::get -song_id $song_id -array sng
	  set song_name [string toupper "$sng(author) $sng(title)"]
	  set sngs($song_name) $song_id
	}
	
	foreach song $songs {
	    # Extract all parts of the song from the filename:
	    # - order_no is the number at the beginning of the filename, without leading 0s
	    # - author is after order_no, separed optionally by a blank
	    # - author ends at the first '-', surrounded by one or more blanks
	    # - everything up to the last dot is the title
	    # - after the last dot we have file extension
	    if {![regexp {^0*(\d+)\s*(.*?)\s+-\s+(.*)\.(.*)$} $song match order_no author title extension]} {
	      # If we could not determine the author because someone forgot the ' - ', just take
	      # the whole filename as title, and as author we will use the playlist's name
	      if {![regexp {^0*(\d+)\s*(.*)\.(.*)$} $song match order_no title extension]} {
		lappend errors "'$song' non è nel formato corretto per un brano"
		continue
	      }
	      set author ""
	    }
	    set author [string trim $author]
	    set title  [string trim $title]

	    # One could just specify an order and
	    # the name for the song will be created
	    # automatically as 'playlist_name order_no'
	    if {$author eq ""} {
		set author $playlist_name
	    }
	    if {$title eq ""} {
		set title $order_no
	    }

	    set song_name [string toupper "$author $title"]
	    set existing_song_p [info exists sngs($song_name)]
	    if {$existing_song_p && !$overwrite_songs_p} {
		lappend errors "brano '$author - $title' già esistente"
		continue
	    }
	    
	    lappend correct_songs $song
	}
	
	if {![info exists correct_songs]} {
	    error "Nessun brano valido contenuto nell'archivio."
	}
	
	set songs $correct_songs
	
    } {
	# Show to user the problems we encountered
	if {[info exists errors]} {
	  util_user_message -html -message "Errori riportati: <br/> - [join $errors "<br/> - "]"
	}

	template::form::set_error addedit zip_file $errmsg
	if {[info exists tmpdir]} {
	  file delete -force -- $tmpdir
	}
	break
    }
    
    # Everything ok, from here we start loading
    db_transaction {
	
	# If playlist exists and we got here, it means we overwrite it...
	if {[info exists plsts($playlist_name_upper)]} {
	    set playlist_id $plsts($playlist_name_upper)
	    cmit::playlist::delete -playlist_id $playlist_id
	}
 
	set playlist_id [cmit::playlist::add \
			     -name                   $playlist_name \
			     -description            $playlist_description \
			     -thumbnail_tmp_filename "$tmpdir/$thumbnail" \
			     -thumbnail_filename     $thumbnail \
			     -valid_from             $valid_from \
			     -valid_to               $valid_to \
			     -locale                 $locale]
	
	set subsite_group_id [cmit::group::get_subsite_group_id]
	
	# Add subsite admins to the groups...
	lappend groups [group::get_rel_segment -group_id $subsite_group_id -type admin_rel]
	
	# ...we grant reading privileges to.
	foreach group_id $groups {
	  permission::grant -party_id $group_id -object_id $playlist_id -privilege read
	}
	
	set playlists [list]
	foreach song $songs {
	    # Extract all parts of the song from the filename:
	    # - order_no is the number at the beginning of the filename, without leading 0s
	    # - author is after order_no, separed optionally by a blank
	    # - author ends at the first '-', surrounded by one or more blanks
	    # - everything up to the last dot is the title
	    # - after the last dot we have file extension
	    if {![regexp {^0*(\d+)\s*(.*?)\s+-\s+(.*)\.(.*)$} $song match order_no author title extension]} {
	      # If we could not determine the author because someone forgot the ' - ', just take
	      # the whole filename as title, and as author we will use the playlist's name
	      regexp {^0*(\d+)\s*(.*)\.(.*)$} $song match order_no title extension ; set author ""
	    }
	    set author [string trim $author]
	    set title  [string trim $title]

	    # One could just specify an order and
	    # the name for the song will be created
	    # automatically as 'playlist_name order_no'
	    if {$author eq ""} {
		set author $playlist_name
	    }
	    if {$title eq ""} {
		set title $order_no
	    }

	    set song_id [cmit::song::add \
		-author       $author \
		-title        $title \
		-filename     $song \
		-tmp_filename "$tmpdir/$song"]
	    # Single songs will be readable by every user of the subsite
	    permission::grant -party_id $subsite_group_id -object_id $song_id -privilege read
	    
	    set song_name [string toupper "$author $title"]
	    # If song existed...
	    if {[info exists sngs($song_name)]} {
		set sng_id $sngs($song_name)
		# ...we replace it into playlists...
		db_dml query "
		  update cmit_playlist_songs set 
		      song_id = :song_id
		    where song_id = :sng_id"
		# (this gets done many times by the procs,
		# but is a good practice to flush cache
		# whenever we touch the db)
		util_memoize_flush_regexp "cmit::"
		# ...then we delete it.
		cmit::song::delete -song_id $sng_id
	    }
	    # Take note of the song with its order
	    lappend playlist_songs [list $song_id $order_no]
	}
	
	# Fill playlist with songs sorted by their order_no
	foreach playlist_song [lsort -integer -index 1 -increasing $playlist_songs] {
	    cmit::playlist::add_song -playlist_id $playlist_id -song_id [lindex $playlist_song 0]
	}
	
	# That's it folks! Let's clean our own mess!
	file delete -force -- $tmpdir

    # If for wathever reason, a loading of a correct playlist fails,
    # we must make sure temp folder is deleted, or we'll stuff the server
    } on_error {
	template::form::set_error addedit zip_file $errmsg
	if {[info exists tmpdir]} {
	  file delete -force -- $tmpdir
	}
    }

    # This will stop form submission if we have errors in the transaction
    if {![template::form::is_valid addedit]} {
	break
    }

} -after_submit {
    
    set mesg "La playlist '$playlist_name' è stata caricata."
    if {[info exists errors]} {
      append mesg "<br/>Errori riportati: <br/> - [join $errors "<br/> - "]"
    }

    ad_returnredirect -html -message $mesg list
    ad_script_abort
    
}
