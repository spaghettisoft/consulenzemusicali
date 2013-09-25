# $Id: toggle-dont-spam-me-p.tcl,v 1.2.26.1 2013/09/07 08:37:59 gustafn Exp $

set user_id [ad_conn user_id]



db_dml unused "update user_preferences set dont_spam_me_p = util.logical_negation(dont_spam_me_p) where user_id = :user_id"

ad_returnredirect "home"
