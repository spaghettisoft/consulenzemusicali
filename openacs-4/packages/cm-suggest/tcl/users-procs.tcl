ad_library {
    User manipulation procedures
    @author Antonio Pisano
}

namespace eval cmit {}



#
### Users procs
#

namespace eval cmit::user {}

ad_proc -public cmit::user::change_state {
    -user_id:required
    -member_state:required
} {
    Change the state of a user
} {
    set subsite_group_id [cmit::group::get_subsite_group_id]
    
    # get user membership to the main subsite
    set rel_id [db_string query "
      select rel_id from acs_rels
    where object_id_one = :subsite_group_id
      and object_id_two = :user_id"]
    
    membership_rel::change_state \
	-rel_id $rel_id \
	-state  $member_state
    
    # if approved, the user becomes also a cmit_user...
    if {$member_state eq "approved"} {
	db_dml query "insert into cmit_users values (:user_id)"
    # ...otherwise it is removed from them
    } else {
	db_dml query "delete from cmit_users where user_id = :user_id"
	# If removed, we don't want him to be member of any group
	foreach group_id [cmit::user::get_groups -user_id $user_id] {
	    cmit::membership::delete -group_id $group_id -user_id $user_id
	}
    }
    
    # flush cache
    util_memoize_flush_regexp "cmit::"
}

# ad_proc -public cmit::user::admin_p {
#     -user_id:required
# } {
#     Gets the groups this uses belongs to
# } {
#     if {![set admin_p \
#       [acs_user::site_wide_admin_p \
# 	-user_id $user_id]]} {
# 	set group_id [cmit::group::get_subsite_group_id]
# 	set admin_p [group::admin_p \
# 	  -group_id $group_id \
# 	  -user_id  $user_id]
#     }
#     return $admin_p
# }

ad_proc -public cmit::user::get_groups_not_cached {
    -user_id:required
} {
    Gets the groups this uses belongs to
} {
    if {![set admin_p \
      [acs_user::site_wide_admin_p \
	-user_id $user_id]]} {
	set group_id [cmit::group::get_subsite_group_id]
	set admin_p [group::admin_p \
	  -group_id $group_id \
	  -user_id  $user_id]
    }
    
    # admins are special...
    if {$admin_p} {
	return [db_list query "
	select group_id from cmit_groups"]
    }
    return [db_list query "
      select distinct object_id_one 
	from acs_rels r, cmit_groups g
    where object_id_one = group_id
      and object_id_two = (
	-- as a safety measure, I further check
	-- that this user is a cmit_user
	select user_id from cmit_users 
	  where user_id = :user_id)"]
}

ad_proc -public cmit::user::get_groups {
    -user_id:required
} {
    Gets the groups this uses belongs to
    
    Uses cache
} {
    return [util_memoize [list cmit::user::get_groups_not_cached -user_id $user_id]]
}

ad_proc -public cmit::user::delete {
    -user_id:required
} {
    Deletes a user
} {
    # remove the user from the cmit_users
    db_dml query "delete from cmit_users where user_id = :user_id"
    
    # I try to erase permanently the user from the system...
    if {[catch {acs_user::delete -user_id $user_id -permanent}]} {
	# ...but it could fail. In that case we just disable it.
	acs_user::delete -user_id $user_id
    }
}



#
### Groups procs
#

namespace eval cmit::group {}

ad_proc -public cmit::group::get_subsite_group_id {
} {
    Get subsite group_id
} {
    # find the subsite root
    array set arr [site_node::get_from_url -url /]
    
    # get the root group for the subsite
    return [application_group::group_id_from_package_id -package_id $arr(package_id)]
}
 
ad_proc -public cmit::group::get_not_cached {
    -group_id:required
    -array:required
} {
    Returns group datas
} {
    upvar $array row
    db_1row query "
      select g.group_id,
             o.title as group_name,
             g.description as group_description,
             cg.thumbnail_id,
             cg.valid_from,
             cg.valid_to,
             cg.order_no
	from groups g, cmit_groups cg, acs_objects o
            where g.group_id   = :group_id
	      and cg.group_id  = :group_id
	      and o.object_id = :group_id
    " -column_array row
    # Get localized group name
    set row(group_name) [_ [string trim $row(group_name) #]]

    set thumbnail_id $row(thumbnail_id)
    
    if {$thumbnail_id ne ""} {
	# Get datas from the file linked to this song
	util::fs::get_file -revision_id $thumbnail_id -array file
	set row(thumbnail_filename)  $file(name)
	set row(thumbnail_size)      $file(content_size)
	set row(thumbnail_mime_type) $file(mime_type)
	set row(thumbnail_url)       $file(url)
    }
    
    return [array get row]
}

ad_proc -public cmit::group::get {
    -group_id:required
    -array:required
} {
    Returns group datas
} {
    upvar $array row
        
    set array [util_memoize [list cmit::group::get_not_cached -group_id $group_id -array row]]
    array set row $array
    
    return $array
}

ad_proc -public cmit::group::add {
    -group_name:required
    {-thumbnail_filename ""}
    {-thumbnail_tmp_filename ""}
    {-valid_from        ""}
    {-valid_to          ""}
} {
    Adds a new group
} {
    # find the subsite root
    array set arr [site_node::get_from_url -url /]

    set context_id $arr(package_id)
    
    # get the root group for the subsite
    set subsite_group_id [application_group::group_id_from_package_id -package_id $context_id]
    
    # add group
    set group_id [group::new \
	-group_name $group_name \
	-context_id $context_id \
	"application_group"]
    
    # The proc for creating a group translates its name with key 'group_title_${group_id}',
    # while the update procs uses 'group_title.${group_id}'. This is bad... 
    # I force an update after the group creation to fix it.
    lang::message::unregister "acs-translations" "group_title_${group_id}"
    
    # update OpenAcs group datas
    set gdatas(group_name) $group_name
    group::update -group_id $group_id -array gdatas
    
    relation_add composition_rel $subsite_group_id $group_id
    
    # If a thumbnail had been specified...
    if {$thumbnail_filename ne ""} {
      # ...which file exists...
      if {[file exists $thumbnail_tmp_filename]} {
	# ...put thumbnail into file storage.
	set thumbnail_id [util::fs::add_file \
	    -name         $thumbnail_filename \
	    -title        "Group $group_name thumbnail" \
	    -description  "Group $group_name thumbnail" \
	    -tmp_filename $thumbnail_tmp_filename]
      }
    # ...else we have no file.
    } else {
	set thumbnail_id ""
    }
       
    # save expiration date of the group
    db_dml query "
      insert into cmit_groups (
	   group_id
	  ,thumbnail_id
	  ,valid_from
	  ,valid_to
	  ,order_no
	) values (
	   :group_id
	  ,:thumbnail_id
	  ,:valid_from
	  ,:valid_to
	  ,(select coalesce(max(order_no), 0) + 1
		  from cmit_groups)
	)"
    
    # flush cache
    util_memoize_flush_regexp "cmit::"
    
    
    return $group_id
}

ad_proc -public cmit::group::edit {
    -group_id:required
    {-group_name ""}
    {-thumbnail_filename ""}
    {-thumbnail_tmp_filename ""}
    -valid_from
    -valid_to
    {-order_no ""}
} {
    Edits a group
} { 
    cmit::group::get -group_id $group_id -array group
    
    set group_name [string trim $group_name]
    if {$group_name eq ""} {
	set group_name $group(group_name)
    }
    if {![info exists valid_from]} {
	set valid_from $group(valid_from)
    }
    if {![info exists valid_from]} {
	set valid_to $group(valid_to)
    }
    
    set old_order_no $group(order_no)
    
    # If a new order is given...
    if {$order_no ne "" && $order_no != $old_order_no} {
	set max_order_no [db_string query "
	  select coalesce(max(order_no), 0)
	    from cmit_groups"]
	# ...it is set to the next max order if greater than that...
	if {$order_no > $max_order_no} {
	    set order_no [expr $max_order_no + 1]
	# ...else we move all the elements which were after this
	# upward, and the ones which will be after this downward. 
	} else {
	    db_dml query "
	      update cmit_groups set
		  order_no = order_no - 1
		where order_no >= :old_order_no;
	      
	      update cmit_groups set
		  order_no = order_no + 1
		where order_no >= :order_no"
	}
    } else {
	# ...else it's just the old order.
	set order_no $old_order_no
    }
    
    set thumbnail_id $group(thumbnail_id)
    
    # If a thumbnail had been specified...
    if {$thumbnail_filename ne ""} {
      # ...which file exists...
      if {[file exists $thumbnail_tmp_filename]} {
	# ...put thumbnail into file storage.
	set thumbnail_id [util::fs::add_file \
	    -name         $thumbnail_filename \
	    -title        "Group $group_name thumbnail" \
	    -description  "Group $group_name thumbnail" \
	    -tmp_filename $thumbnail_tmp_filename]
      }
    }
    
    # update OpenAcs group datas
    set gdatas(group_name) $group_name
    group::update -group_id $group_id -array gdatas
    
    # save expiration date of the group
    db_dml query "
      update cmit_groups set
	   thumbnail_id = :thumbnail_id
	  ,valid_from   = :valid_from
	  ,valid_to     = :valid_to
	  ,order_no     = :order_no
	where group_id = :group_id"
    
    # flush cache
    util_memoize_flush_regexp "cmit::"
}

ad_proc -public cmit::group::delete {
    -group_id:required
} {
    Deletes a group
} { 
    # Remove all members from group
    foreach membership_id [db_list query "
      select membership_id 
	from cmit_memberships m,
	     acs_rels r
    where rel_type      = 'membership_rel' 
      and object_id_one = :group_id 
      and r.rel_id      = m.membership_id"] {
      cmit::membership::delete -membership_id $membership_id
    }
    
    # delete the group updating the ordering
    db_dml query "
      update cmit_groups set
	   order_no = order_no - 1
	where order_no > (
	    select order_no from cmit_groups
	      where group_id = :group_id);
      
      delete from cmit_groups 
	where group_id = :group_id"
    
    lang::message::unregister "acs-translations" "group_title.${group_id}"
    group::delete $group_id
    
    # flush cache
    util_memoize_flush_regexp "cmit::"
}

ad_proc -public cmit::group::thumbnail_delete {
    -group_id:required
} {
    Deletes a group's thumbnail
} { 
    # Delete thumbnail_id
    set thumbnail_id [db_string query "
      select thumbnail_id from cmit_groups
    where group_id = :group_id"]

    # Delete thumbnail reference in group
    db_dml query "
      update cmit_groups set
	  thumbnail_id = null
	where group_id = :group_id"
        
    if {$thumbnail_id ne ""} {
	set file_id [db_string query "
	  select item_id from cr_revisions
	where revision_id = :thumbnail_id"]
	
	fs::delete_version -item_id $file_id -version_id $thumbnail_id
    }
    
    # flush cache
    util_memoize_flush_regexp "cmit::"
}

#
### Membership procs
#

namespace eval cmit::membership {}

ad_proc -public cmit::membership::get {
    -membership_id:required
    -array:required
} {
    Gets a membership
} { 
    upvar $array row
    db_1row query "
      select m.*,
             r.object_id_one as group_id,
	     r.object_id_two as member_id
	from cmit_memberships m,
	     acs_rels r
    where r.rel_id = m.membership_id
      and membership_id = :membership_id
    " -column_array row
}

ad_proc -public cmit::membership::add {
    -group_id:required
    -member_id:required
    {-valid_from ""}
    {-valid_to   ""}
} {
    Adds a user to a group
} { 
    # create membership relationship
    set rel_id [relation_add -member_state approved membership_rel $group_id $member_id]
    
    db_dml query "
      insert into cmit_memberships (
	    membership_id
	   ,valid_from
	   ,valid_to
	  ) values (
	    :rel_id
	   ,:valid_from
	   ,:valid_to
	  )"
    
    # flush cache
    util_memoize_flush_regexp "cmit::"
    
    
    return $rel_id
}

ad_proc -public cmit::membership::edit {
    -membership_id:required
    -member_id
    -valid_from
    -valid_to
} {
    Edits a membership
} {
    cmit::membership::get -membership_id $membership_id -array membership
    
    foreach var [array names membership] {
	if {![info exists $var]} {
	    set $var $membership($var)
	}
    }
    
    db_dml query "
      update cmit_memberships set
	  valid_from = :valid_from,
	  valid_to   = :valid_to
	where membership_id = :membership_id;
      
      update acs_rels set
	  object_id_two = :member_id
	where rel_id = :membership_id"
    
    # flush cache
    util_memoize_flush_regexp "cmit::"
}

ad_proc -public cmit::membership::delete {
    {-membership_id ""}
    {-group_id      ""}
    {-member_id     ""}
} {
    Deletes a member from a group
} {
    # all the relationships between user and group...
    if {$membership_id eq ""} {
      if {$group_id eq "" || $member_id eq ""} {
	  return
      }
      set rels [db_list query "
	select rel_id from acs_rels 
      where object_id_one = :group_id 
	and object_id_two = :member_id"]
    # ...or a single membership
    } else {
	set rels $membership_id
	db_1row query "
	  select object_id_one as group_id,
	         object_id_two as member_id
	      from acs_rels
	    where rel_id = :membership_id"
    }
    
    foreach rel_id $rels {
	db_dml query "
	  delete from party_approved_member_map 
	where member_id = :member_id 
	  and tag       = :rel_id;
    
	  delete from cmit_memberships
	where membership_id = :rel_id"
    }

    group::remove_member \
        -group_id $group_id \
        -user_id  $member_id
    
    # flush cache
    util_memoize_flush_regexp "cmit::"
}