ad_page_contract {

  @author Antonio Pisano

} {
    {group_id ""}
}


set new_record_p [expr {$group_id eq ""}]

if {!$new_record_p} {
    set page_title "Modifica Gruppo"
} else {
    set page_title "Crea Gruppo"
}

set context [list [list list {Elenco gruppi}] $page_title]

set this_url [export_vars -base [ad_conn url] -entire_form -no_empty]


set form {}

if {!$new_record_p} {
    append form {
	{order_no:integer,optional
	    {label "N° ordine"}
	    {html {size 3}}
	    {help_text "Non cambia se non digitato."}
	}
    }
}

append form {
    {group_name:text
	{label {Nome Gruppo}}
	{html {size 30}}
    }
    {valid_from:date,optional
	{label {Valido da}}
    }
    {valid_to:date,optional
	{label {Valido a}}
    }
}

if {!$new_record_p} {
    append form {
	{filename:text(inform)
	    {label "Thumbnail caricata"}
	}
    }
}

append form {
    {file:file(file),optional
	{label "Nuova thumbnail"}
    }
}

ad_form -html { enctype multipart/form-data } -name addedit \
    -edit_buttons [list [list "$page_title" new]] \
    -export group_id \
    -has_edit 1 \
    -form $form \
  -on_request {

    if {!$new_record_p} {
        cmit::group::get -group_id $group_id -array group
	
	set group_name $group(group_name)
	set valid_from $group(valid_from)
	if {$valid_from ne ""} {
	    util_unlist [split $valid_from -] year month day
	    set valid_from "$year $month $day"
	}
	set valid_to $group(valid_to)
	if {$valid_to ne ""} {
	    util_unlist [split $valid_to -] year month day
	    set valid_to "$year $month $day"
	}
	
	set thumbnail_id $group(thumbnail_id)
	if {$thumbnail_id ne ""} {
	    set filename      $group(thumbnail_filename)
	    set thumbnail_url $group(thumbnail_url)
	    
	    set thumbnail_delete_url [export_vars -base "thumbnail-delete" {group_id {return_url $this_url}}]
	    template::element::set_properties addedit filename before_html "
		<img src='$thumbnail_url' height='50'/>
		<a href='$thumbnail_delete_url' title='Elimina questa thumbnail'>
		  <img src='/resources/acs-subsite/Delete16.gif' width='16' height='16' border='0'/>
		</a>"
	}
    }

} -on_submit {
    
    set group_name [string trim $group_name]
    if {$group_name eq ""} {
	template::form::set_error addedit group_name "E' necessario fornire un nome per il gruppo."
    }
    
    if {$valid_from ne ""} {
	set valid_from_ansi [join [lrange $valid_from 0 2] -]
    } else {
	set valid_from_ansi ""
    }
    if {$valid_to ne ""} {
	set valid_to_ansi [join [lrange $valid_to 0 2] -]
    } else {
	set valid_to_ansi ""
    }
    
    if {$file ne ""} {
      util_unlist $file filename file.tmpfile mime_type
	  
      if {![regexp ^image/.* $mime_type]} {
	  template::form::set_error addedit file "Il formato del file inviato non è supportato."
      }
    } else {
	set filename ""
	set file.tmpfile ""
    }
    
    if {![template::form::is_valid addedit]} {
	break
    }
    

    if {$new_record_p} {

	db_transaction {
	    
	    cmit::group::add \
		-group_name $group_name \
		-thumbnail_filename     $filename \
		-thumbnail_tmp_filename ${file.tmpfile} \
		-valid_from $valid_from_ansi \
		-valid_to   $valid_to_ansi

	}

    } else {

	db_transaction {

	    cmit::group::edit -group_id $group_id \
		-thumbnail_filename     $filename \
		-thumbnail_tmp_filename ${file.tmpfile} \
		-group_name $group_name \
		-valid_from $valid_from_ansi \
		-valid_to   $valid_to_ansi \
		-order_no   $order_no

	}

    }

} -after_submit {
    ad_returnredirect "list"
    ad_script_abort
}


if {!$new_record_p} {
    foreach locale {
	en_US
	it_IT
	es_ES
	fr_FR
	de_DE
	pt_BR
    } {
	set desired_locales($locale) 1
    }
	
    template::list::create \
	-name translations \
	-multirow translations \
	-actions [list] \
	-elements {
	    edit {
		link_url_col edit_url
		display_template {<img src="/resources/acs-subsite/Edit16.gif" width="16" height="16" border="0">}
		link_html {title "Modifica Traduzione"}
		sub_class narrow
	    }
	    locale {
		label "Lingua"
	    }
	    translation {
		label "Traduzione"
	    }
	}
	
    template::multirow create translations edit_url locale translation
    set translation_key [string trim [group::title -group_id $group_id] #]
    set default_translation [_ $translation_key]
    foreach lc [lang::util::get_locale_options] {
	set locale [lindex $lc 1]
	if {![info exists desired_locales($locale)]} continue
	set translation [lang::message::lookup $locale $translation_key $default_translation]
	set edit_url [export_vars -base "translate" {group_id locale}]
	template::multirow append translations $edit_url $locale $translation
    }
}

