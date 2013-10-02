ad_page_contract {
    displays the iso-codes

    @cvs-id $Id: iso-codes.tcl,v 1.2.26.1 2013/09/28 15:27:59 gustafn Exp $
} -properties {
    ccodes:multirow
}

if {![db_table_exists countries] } {
    # acs-reference countries not loaded

    ad_return_template iso-codes-no-exist
    return
}

db_multirow ccodes country_codes "select iso, default_name from countries order by default_name" 

ad_return_template