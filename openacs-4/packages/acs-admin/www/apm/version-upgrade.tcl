ad_page_contract {

    Upgrades an older version of a package to one that a newer version that is locally
    maintained.

    @author Bryan Quinn (bquinn@arsdigita.com)
    @creation-date Thu Oct 12 17:45:38 2000
    @cvs-id $Id: version-upgrade.tcl,v 1.1.1.1.28.1 2013/09/28 12:10:01 gustafn Exp $
} {
    version_id
}
apm_version_info $version_id

set title "Upgrading to $pretty_name $version_name"
set context [list \
		 [list "/acs-admin/apm/" "Package Manager"] \
		 [list "version-view?version_id=$version_id" "$pretty_name $version_name"] \
		 $title]

# Disable all previous versions of this packae.
apm_version_upgrade $version_id

# Instruct user to run SQL upgrade scripts.
set body [subst {
    <p>
    $pretty_name $version_name has been enabled.  Please run any necessary
    SQL upgrade scripts to finish updating the data model and restart
    the server.
}]

ad_return_template apm
