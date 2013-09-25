ad_page_contract {

    @author Antonio Pisano

} {
}

auth::require_login

# current connection 
# variables we need
set connvars {
  user_id
  package_key
}

# parameters we need
set params {
  jquery_path
}

foreach connvar $connvars {
  set $connvar [ad_conn $connvar]
}

foreach param $params {
  if {[set $param [parameter::get -parameter $param -default ""]] eq ""} {
    ad_complain "Parametro $param non impostato." ; return
  }
}

# load this java libraries
# in respective orders
set order 0
foreach lib {
  jquery_path 
} {
  template::head::add_javascript -src [set $lib] -order $order
  incr order
}

# set page_title "Gruppi"
# set doc(title) $page_title


# All groups this user is member of
template::multirow create groups group_id name
foreach group_id \
  [cmit::user::get_groups -user_id $user_id] {
    cmit::group::get -group_id $group_id -array group
    
    set name $group(group_name)
    
    set thumbnail_id $group(thumbnail_id)
    if {$thumbnail_id ne ""} {
      lappend thumbnails $group(thumbnail_url)
    }
    
    template::multirow append groups $group_id $name
}

set n_groups [template::multirow size groups]