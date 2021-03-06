ad_page_contract {

    Select, dependency check, install and enable packages.

    @author Bryan Quinn (bquinn@arsdigita.com)
    @cvs-id $Id: packages-install.tcl,v 1.22.4.5 2013/10/17 08:44:30 gustafn Exp $

} {
    {checked_by_default_p:boolean 0}
}

set title "Package Installation"
set context [list [list "/acs-admin/apm/" "Package Manager"] $title]

ad_return_top_of_page [ad_parse_template -params [list context title] \
			   "/packages/openacs-default-theme/lib/plain-streaming-head"]

### Get all the spec files
#
# If a package is in the apm_workspace dir then we assume that that is
# the package that should be installed and we ignore any such package
# in the packages dir.  
#
# TODO: make sure that it's a later version than that in the packages dir?
#
set packages_root_dir "$::acs::rootdir/packages"
set packages_spec_files [apm_scan_packages $packages_root_dir]
set workspace_spec_files [apm_scan_packages [apm_workspace_install_dir]]
set workspace_filenames [list]
foreach spec_path $workspace_spec_files {
    lappend workspace_filenames [file tail $spec_path]
}
set all_spec_files $workspace_spec_files
foreach spec_path $packages_spec_files {
    set spec_filename [file tail $spec_path]
    if {$spec_filename ni $workspace_filenames} {
        lappend all_spec_files $spec_path
    }
}

# Determine which spec files are new installs; install all of the new items.
set spec_files [list]
set already_installed_list [list]
set not_compatible_list [list]

foreach spec_file $all_spec_files {
    array set version [apm_read_package_info_file $spec_file]
    set version_name $version(name)
    set package_name $version(package-name)
    set package_key $version(package.key)
    if { [apm_package_supports_rdbms_p -package_key $package_key] } {
        if { [apm_package_registered_p $package_key] } {
            # This package is already on the system
            if { [apm_higher_version_installed_p $package_key $version_name] } {
                ns_log Notice "higher version installed of $package_key $version_name"
                lappend spec_files $spec_file
            } else {
                ns_log Notice "need upgrade of package $package_key $version_name"
                lappend already_installed_list \
		    "Package &quot;$package_name&quot; ($package_key) version $version_name or higher is already installed."
            }
        } else {
            lappend spec_files $spec_file
        }
    } else {
        lappend not_compatible_list "Package &quot;$package_name&quot; ($package_key) doesn't support [db_type]."
    }
}

apm_log APMDebug $spec_files

if { $spec_files eq "" } {
    # No spec files to work with.
    ns_write [subst {
    <h2>No New Packages to Install</h2><p>

    There are no new packages to install.  Please load some
    using the <a href="package-load">Package Loader</a>.<p>
    Return to the <a href="index">APM</a>.<p>
    }]
} else {   
    
    ns_write {
    <h2>Select Packages to Install</h2><p>
    <p>Please select the set of packages you'd like to install.</p>
    }

    ns_write [subst {

<script type="text/javascript">
function uncheckAll() {
    for (var i = 0; i < [llength $spec_files]; ++i)
        document.forms\[0\].elements\[i\].checked = false;
    this.href='';
}
function checkAll() {
    for (var i = 0; i < [llength $spec_files]; ++i)
        document.forms\[0\].elements\[i\].checked = true;
    this.href='';
}
</script>
<a href="packages-install?checked_by_default_p=0" onclick="javascript:uncheckAll();return false"><b>uncheck all boxes</b></a> |
<a href="packages-install?checked_by_default_p=1" onclick="javascript:checkAll(); return false"><b>check all boxes</b></a>
    }]

    ns_write "<form action=packages-install-2 method=post>"

    # Client properties do not deplete the limited URL variable space.
    # But they are limited to the maximum length of a varchar ...

    ad_set_client_property -clob t apm spec_files $spec_files

    set errors [list]
    set pkg_info_list [list]
    set pkg_key_list [list]
    apm_log APMDebug "APM: Specification files available: $spec_files"
    foreach spec_file $spec_files {
	### Parse the package.
	if { [catch {
	    array set package [apm_read_package_info_file $spec_file]
	} errmsg] } {
	    lappend errors "<li>Unable to parse $spec_file.  The following error was generated:
	    <blockquote><pre>[ad_quotehtml $errmsg]</pre></blockquote><p>"
	} else {
	    apm_log APMDebug "APM: Adding $package(package.key) to list for installation." 
	    lappend pkg_info_list [pkg_info_new $package(package.key) $spec_file \
		    $package(embeds) $package(extends) $package(provides) $package(requires) ""]
            lappend pkg_key_list $package(package.key)
	}
    }
	
    if { $checked_by_default_p } {
        set widget [apm_package_selection_widget $pkg_info_list $pkg_key_list $pkg_key_list]
    } else {
        set widget [apm_package_selection_widget $pkg_info_list]
}

    if {$widget eq ""} {
	ns_write "There are no new packages available."
	ad_script_abort
    }

    ns_write $widget
    ns_write [subst {
    <input type="submit" value="Next -->">
    </form>
    }]
    
    if {$errors ne ""} {
	ns_write "The following errors were generated
	<ul>
	    $errors
	</ul>
	"
    }    
}

if { [llength $not_compatible_list] > 0 } {
    ns_log Notice "APM packages-install: Incompatible Packages\n- [join $not_compatible_list "\n- "]"
}

if { [llength $already_installed_list] > 0 } {
    ns_log Notice "APM packages-install: Already Installed Packages\n- [join $already_installed_list "\n- "]"
}
