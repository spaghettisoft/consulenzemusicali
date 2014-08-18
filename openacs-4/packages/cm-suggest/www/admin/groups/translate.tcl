ad_page_contract {

  @author Antonio Pisano

} {
    group_id
    locale
}

set translation_key [string trim [group::title -group_id $group_id] #]

set group_name [_ $translation_key]

set page_title "Traduzione Gruppo '$group_name' lingua '$locale'"

set return_url [export_vars -base "add-edit" {group_id}]

set context [list [list list {Elenco gruppi}] [list $return_url "Modifica Gruppo"] $page_title]

ad_form -name addedit \
    -export {group_id locale} \
    -form {
    {translation:text
	{label "Traduzione"}
	{html {size 30}}
    }
} -on_request {

    set translation [lang::message::lookup $locale $translation_key $group_name]

} -on_submit {
    
    set translation [string trim $translation]
    if {$translation ne ""} {
	set msg_key_tokens [split $translation_key .]
	set package_key [lindex $msg_key_tokens 0]
	set message_key [join [lrange $msg_key_tokens 1 end] .]
	lang::message::register $locale $package_key $message_key $translation
    }

} -after_submit {
    ad_returnredirect -message "La traduzione è stata salvata." $return_url
    ad_script_abort
}
