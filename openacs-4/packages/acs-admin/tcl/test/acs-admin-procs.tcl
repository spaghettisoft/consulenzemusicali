ad_library {
    Automated tests.

    @author Joel Aufrecht
    @creation-date 2 Nov 2003
    @cvs-id $Id: acs-admin-procs.tcl,v 1.3.20.2 2013/09/28 15:40:57 gustafn Exp $
}

aa_register_case -cats {api smoke} apm_higher_version_installed_p {
    Test apm_higher_version_installed_p proc.
} {    

    aa_run_with_teardown \
        -rollback \
        -test_code {

            set is_lower [apm_higher_version_installed_p acs-admin "1"]
            aa_equals "is the version of acs-admin higher than 0.1d?" $is_lower -1

            set is_higher [apm_higher_version_installed_p acs-admin "1000"]
            aa_equals "is the version of acs-admin lower than 1000.1d?" $is_higher 1

        }
}
