ad_library {

    Initialization code for database routines.

    @creation-date 7 Aug 2000
    @author Jon Salz (jsalz@arsdigita.com)
    @cvs-id $Id: database-init.tcl,v 1.4 2013/02/21 14:17:52 victorg Exp $

}

#DRB: the default value is needed during the initial install of OpenACS
ns_cache create db_cache_pool -size \
    [parameter::get -package_id [ad_acs_kernel_id] -parameter DBCacheSize -default 50000]
