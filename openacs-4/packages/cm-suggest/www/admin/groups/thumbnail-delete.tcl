ad_page_contract {

  @author Antonio Pisano

} {
    group_id:integer
    return_url
}

db_transaction {
    cmit::group::thumbnail_delete -group_id $group_id
}

ad_returnredirect $return_url
ad_script_abort
