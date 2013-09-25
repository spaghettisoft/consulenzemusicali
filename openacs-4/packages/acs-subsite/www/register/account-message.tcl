ad_page_contract {
    Inform the user of an account status message.
    
    @cvs-id $Id: account-message.tcl,v 1.1.22.1 2013/09/02 10:43:49 gustafn Exp $
} {
    {message:html ""}
    {return_url ""}
}

set page_title "Logged in"
set context [list $page_title]

set system_name [ad_system_name]

