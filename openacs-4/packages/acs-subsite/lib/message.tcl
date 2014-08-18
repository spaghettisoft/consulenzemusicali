ad_page_contract {
    This include expects "message" to be set as html
    and if no title is present uses "Message".  Used to inform of actions
    in registration etc.

    @cvs-id $Id: message.tcl,v 1.1.16.1 2013/10/05 13:02:11 gustafn Exp $
}
if {(![info exists title] || $title eq "")} {
    set page_title Message
}
set context [list $title]
