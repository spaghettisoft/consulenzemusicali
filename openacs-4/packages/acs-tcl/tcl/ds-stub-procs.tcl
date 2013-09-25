ad_library {
    Stub procs for developer support procs we call in acs-tcl
    for logging.  We check here if the procs are defined
    before we stub them out.

    This is done since the old ad_call_proc_if_exists
    is somewhat expensive and these are called a lot in 
    every request.

    @author Jeff Davis <davis@xarg.net>
    @creationd-date 2005-03-02
    @cvs-id $Id: ds-stub-procs.tcl,v 1.3 2012/12/08 17:42:32 gustafn Exp $
}

if {[info commands ds_add] eq ""} {
    proc ds_add {args} {}
}
if {[info commands ds_collect_db_call] eq ""} {
    proc ds_collect_db_call {args} {}
}
if {[info commands ds_collect_connection_info] eq ""} {
    proc ds_collect_connection_info {} {}
}
