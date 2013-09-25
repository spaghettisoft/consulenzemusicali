ad_page_contract {

    Uses OpenAcs background delivery thread to serve a file into filestorage
    
    @author Antonio Pisano

} {
    object_id:integer
}

set user_id [ad_conn user_id]

permission::require_permission -party_id $user_id \
    -object_id $object_id -privilege "read"

db_1row query "
  select live_revision as revision_id,
         mime_type
    from fs_objects
where object_id = :object_id
  and mime_type is not null"

set filename [content::revision::get_cr_file_path -revision_id $revision_id]

ad_returnfile_background 200 $mime_type $filename
ad_script_abort
