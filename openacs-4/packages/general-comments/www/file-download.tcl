# /packages/general-comments/www/file-download.tcl

ad_page_contract {
    Downloads a file

    @param item_id The id of the file attachment

    @author Phong Nguyen (phong@arsdigita.com)
    @author Pascal Scheffers (pascal@scheffers.net)
    @creation-date 2000-10-12
    @cvs-id $Id: file-download.tcl,v 1.3.26.1 2013/09/06 16:01:50 gustafn Exp $
} {
    item_id:notnull
}

# check for permissions
permission::require_permission -object_id $item_id -privilege read

cr_write_content -item_id $item_id
