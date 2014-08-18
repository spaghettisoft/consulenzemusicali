ad_library {

    Community routines (dealing with users, parties, etc.).
    Redone with scoping and nice abstraction (Ben)

    @author Ben Adida (ben@openforce.net)
    @creation-date May 29th, 2002
    @cvs-id $Id: community-core-2-procs.tcl,v 1.2.26.1 2013/10/07 19:53:12 gustafn Exp $

}

# The User Namespace
namespace eval oacs::user {

    ad_proc -deprecated -public get {
        {-user_id:required}
        {-array:required}
    } {
        Load up user information
    } {
        # Upvar the Tcl Array
        upvar $array row
        db_1row select_user {} -column_array row
    }

}
