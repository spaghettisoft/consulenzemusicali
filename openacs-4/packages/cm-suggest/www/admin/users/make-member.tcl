ad_page_contract {
    Make ordinary members.
} {
    {user_id:multiple ""}
}

# find the subsite root
array set arr [site_node::get_from_url -url /]

# get the root group for the subsite
set group_id [application_group::group_id_from_package_id -package_id $arr(package_id)]


if {[lsearch $user_id [ad_conn user_id]] > 0} {
    ad_return_complaint 1 "Non e' possibile eliminare il proprio utente dagli amministratori."
    ad_script_abort
}

db_transaction {
    foreach one_user_id $user_id {
        db_1row get_rel_id {}
        relation_remove $rel_id
	permission::revoke -party_id $one_user_id -object_id [ad_conn package_id] -privilege admin
    }
    # flush cache
    util_memoize_flush_regexp "cmit::"
} on_error {
    ad_return_error "Error creating the relation" "We got the following error message while trying to create this relation: <pre>$errmsg</pre>"
    ad_script_abort
}

ad_returnredirect list
ad_script_abort
