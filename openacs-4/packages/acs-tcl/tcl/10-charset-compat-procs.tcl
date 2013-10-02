ad_library {
    
    Compatibily procs in case we're not running a version of AOLServer that supports charsets.
    
    @author Rob Mayoff [mayoff@arsdigita.com]
    @author Nada Amin [namin@arsdigita.com]
    @creation-date June 28, 2000
    @cvs-id $Id: 10-charset-compat-procs.tcl,v 1.1.28.1 2013/09/30 11:22:00 gustafn Exp $
}

set compat_procs [list ns_startcontent ns_encodingfortype]

foreach one_proc $compat_procs {
    if {[llength [info commands $one_proc]] == 0} {
	proc $one_proc {args} { }
    }
}

