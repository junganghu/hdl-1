################################################################################
################################################################################

proc adi_device_spec {cellpath param} {

  set ip [get_bd_cells $cellpath]
  set ip_path [bd::get_vlnv_dir [get_property VLNV $ip]]
  # can't use global variables
  set parent_dir "../"
  for {set x 1} {$x<=4} {incr x} {
    set linkname ${ip_path}${parent_dir}scripts/adi_device_info_enc.tcl
    if { [file exists $linkname] } {
      source ${ip_path}${parent_dir}/scripts/adi_device_info_enc.tcl
      break
    }
    append parent_dir $parent_dir
  }

  set part [get_property PART [current_project]]

  switch -regexp -- $param {
      FPGA_SERIES {
          switch  -regexp -- $part {
             ^xc7    {set series_name 7series}
             ^xczu   {set series_name ultrascale+}
             ^xc.u.p {set series_name ultrascale+}
             ^xc.u   {set series_name ultrascale }
             default {
                 puts "Undefined fpga series for \"$part\"!"
                 exit -1
             }
          }
          set_property CONFIG.FPGA_SERIES "$series_name" $ip
      }
      FPGA_FAMILY {
          set fpga_family [get_property FAMILY $part]
          foreach i $fpga_family_list {
              regexp ^[lindex $i 0] $fpga_family matched
          }
          set_property CONFIG.FPGA_FAMILY "$matched" $ip
      }
      SPEED_GRADE {
          set speed_grade [get_property SPEED $part]
          set_property CONFIG.SPEED_GRADE "$speed_grade" $ip
      }
      DEV_PACKAGE {
          set dev_package [get_property PACKAGE $part]
          foreach i $dev_package_list {
              regexp ^[lindex $i 0] $dev_package matched
          }
          set_property CONFIG.DEV_PACKAGE "$matched" $ip
      }
      XCVR_TYPE {
          set matched ""
          set dev_transcivers "none"
          foreach x [list_property $part] {
              regexp ^GT..._TRANSCEIVERS $x dev_transcivers
          }
          foreach i $xcvr_type_list {
              regexp ^[lindex $i 0] $dev_transcivers matched
          }
          if { $matched eq "" } {
               puts "CRITICAL WARNING: \"$dev_transcivers\" TYPE IS NOT SUPPORTED BY ADI!"
          }
          set_property CONFIG.XCVR_TYPE "$matched" $ip
      }
      default {
          puts "WARNING: UNDEFINED PARAMETER \"$param\" (adi_device_spec)!"
      }
  }
}

# auto set parameters defined in auto_set_param_list (adi_device_info_enc.tcl)
proc adi_auto_assign_device_spec {cellpath} {

  set ip [get_bd_cells $cellpath]
  set ip_param_list [list_property $ip]
  set ip_path [bd::get_vlnv_dir [get_property VLNV $ip]]

  set parent_dir "../"
  for {set x 1} {$x<=4} {incr x} {
    set linkname ${ip_path}${parent_dir}scripts/adi_device_info_enc.tcl
    if { [file exists $linkname] } {
      source ${ip_path}${parent_dir}/scripts/adi_device_info_enc.tcl
      break
    }
    append parent_dir $parent_dir
  }

  # Find predefindes auto assignable parameters
  foreach i $auto_set_param_list {
      if { [lsearch $ip_param_list "CONFIG.$i"] > 0 } {
          adi_device_spec $cellpath $i
      }
  }
}
