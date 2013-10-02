# /packages/mbryzek-subsite/www/admin/attributes/value-delete-2.tcl

ad_page_contract {

    Deletes a value

    @author mbryzek@arsdigita.com
    @creation-date Sun Dec 10 14:48:44 2000
    @cvs-id $Id: value-delete-2.tcl,v 1.2.10.4 2013/09/09 16:44:19 gustafn Exp $

} {
    attribute_id:naturalnum,notnull
    enum_value:trim,notnull
    { operation:trim "No, I want to cancel my request" } 
    { return_url "one?[export_vars attribute_id]" }    
}

if {$operation eq "Yes, I really want to delete this attribute value"} {
    db_transaction {
	attribute::value_delete $attribute_id $enum_value
    }
}

ad_returnredirect $return_url
