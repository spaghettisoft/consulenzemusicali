ad_page_contract {

  @author Antonio Pisano

} {
    song_id:multiple
    {force_p f}
}

set return_url list

set n_songs [llength $song_id]
if {$n_songs == 1} {
  # ad_form doesn't export multiple values properly,
  # so if list of songs is made by only one element,
  # I must check further if it is in fact a string
  # of multiple elements.
  set song_id [lindex $song_id 0]
  set n_songs [llength $song_id]

  # If only one song, don't need confirmation,
  # it is already done by javascript in previous
  # page
  if {$n_songs == 1} {
    set force_p t
  }
}

set page_title "\#file-storage.Delete\#"
set context [list [list list {Elenco Brani}] $page_title]

if {$force_p ne t} {

  ad_form \
    -name delete_confirm \
    -export {{force_p t} song_id} \
    -cancel_url $return_url \
    -form {
      {notice:text(inform) 
	{label ""} 
	{value "Sei sicuro di voler eliminare questi $n_songs brani?"}
      }
  } -on_submit {}

} else {

  db_transaction {
      set songs $song_id
      foreach song_id $songs {
	  cmit::song::delete -song_id $song_id
      }
  }

  if {$n_songs > 1} {
      set msg "I brani indicati sono stati cancellati."
  } else {
      set msg "Il brano indicato e' stato cancellato."
  }

  ad_returnredirect -message $msg $return_url
  ad_script_abort

}



