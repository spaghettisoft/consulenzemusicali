ad_page_contract {
    A hack that will allow us to simulate being a different user
} {
    user_id:integer
    return_url
}

##NOTE THIS DOESN'T REQUIRE ADMIN SO THAT WE CAN DO USER SWITCHING
permission::require_permission -object_id [ad_conn package_id] -privilege "read"

ad_set_client_property developer-support user_id $user_id

ad_returnredirect $return_url
