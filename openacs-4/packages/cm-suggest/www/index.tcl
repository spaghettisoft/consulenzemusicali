ad_page_contract {

    @author Antonio Pisano

} {
}

# If user is not logged in 
# we'll show the login url
set logged_p [acs_user::registered_user_p]
if {!$logged_p} {
  set login_url [ad_get_login_url -return]
} else {
  set logout_url [ad_get_logout_url -return]
}

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
    set errmsg "Parametro $param non impostato."
    ad_return_error $errmsg $errmsg
  }
}

set this_js [util::get_script_name].js

# load this java libraries
# in respective orders
set order 0
foreach lib {
  jquery_path 
  this_js
} {
  template::head::add_javascript -src [set $lib] -order $order
  incr order
}

# Add css
#template::head::add_css -href "css/style.css"

# set page_title "Gruppi"
# set doc(title) $page_title


# All groups this user is member of
set thumbnails [list]

template::multirow create groups group_id order_no name thumbnail_url

foreach group_id \
  [cmit::user::get_groups -user_id $user_id] {
    cmit::group::get -group_id $group_id -array group
    set name         $group(group_name)
    set thumbnail_id $group(thumbnail_id)
    set order_no     $group(order_no)
    
    if {$thumbnail_id ne ""} {
      set thumbnail_url $group(thumbnail_url)
    } else {
      set thumbnail_url ""
    }
    
    template::multirow append groups $group_id $order_no $name $thumbnail_url
}

template::multirow sort groups -integer order_no

set n_groups [template::multirow size groups]
