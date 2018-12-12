###################################################################################################
###################################################################################################
# keep interface-mess out of the way - keeping it pretty is a waste of time

proc ad_alt_intf {type name dir width {arg_1 ""} {arg_2 ""}} {

  if {([string equal -nocase ${type} "clock"]) && ([string equal -nocase ${dir} "input"])} {
    add_interface if_${name} clock sink
    add_interface_port if_${name} ${name} clk ${dir} ${width}
    return
  }

  if {([string equal -nocase ${type} "clock"]) && ([string equal -nocase ${dir} "output"])} {
    add_interface if_${name} clock source
    add_interface_port if_${name} ${name} clk ${dir} ${width}
    return
  }

  if {([string equal -nocase ${type} "reset"]) && ([string equal -nocase ${dir} "input"])} {
    add_interface if_${name} reset sink
    add_interface_port if_${name} ${name} reset ${dir} ${width}
    set_interface_property if_${name} associatedclock ${arg_1}
    return
  }

  if {([string equal -nocase ${type} "reset"]) && ([string equal -nocase ${dir} "output"])} {
    add_interface if_${name} reset source
    add_interface_port if_${name} ${name} reset ${dir} ${width}
    set_interface_property if_${name} associatedclock ${arg_1}
    set_interface_property if_${name} associatedResetSinks ${arg_2}
    return
  }

  if {([string equal -nocase ${type} "reset-n"]) && ([string equal -nocase ${dir} "input"])} {
    add_interface if_${name} reset sink
    add_interface_port if_${name} ${name} reset_n ${dir} ${width}
    set_interface_property if_${name} associatedclock ${arg_1}
    return
  }

  if {([string equal -nocase ${type} "reset-n"]) && ([string equal -nocase ${dir} "output"])} {
    add_interface if_${name} reset source
    add_interface_port if_${name} ${name} reset_n ${dir} ${width}
    set_interface_property if_${name} associatedclock ${arg_1}
    set_interface_property if_${name} associatedResetSinks ${arg_2}
    return
  }

  if {([string equal -nocase ${type} "intr"]) && ([string equal -nocase ${dir} "output"])} {
    add_interface if_${name} interrupt source
    add_interface_port if_${name} ${name} irq ${dir} ${width}
    set_interface_property if_${name} associatedclock ${arg_1}
    return
  }

  set remap $arg_1
  if {$arg_1 eq ""} {
    set remap $name
  }

  if {[string equal -nocase ${type} "signal"]} {
    add_interface if_${name} conduit end
    add_interface_port if_${name} ${name} ${remap} ${dir} ${width}
    return
  }
}

proc ad_conduit {if_name if_port port dir width} {

  add_interface $if_name conduit end
  add_interface_port $if_name $port $if_port $dir $width
}

proc ad_generate_module_inst { inst_name mark source_file target_file } {

  set fp_source [open $source_file "r"]
  set fp_target [open $target_file "w+"]

  fconfigure $fp_source -buffering line

  while { [gets $fp_source data] >= 0 } {

    # update the required module name
    regsub $inst_name $data "&_$mark" data
    puts $data
    puts $fp_target $data
  }

  close $fp_source
  close $fp_target
}

###################################################################################################
###################################################################################################

proc ad_ip_create {pname pdisplay_name {pelabfunction ""} {pcomposefunction ""}} {

  set_module_property NAME $pname
  set_module_property DISPLAY_NAME $pdisplay_name
  set_module_property DESCRIPTION $pdisplay_name
  set_module_property VERSION 1.0
  set_module_property GROUP "Analog Devices"

  if {$pelabfunction ne ""} {
    set_module_property ELABORATION_CALLBACK $pelabfunction
  }

  if {$pcomposefunction ne ""} {
    set_module_property COMPOSITION_CALLBACK $pcomposefunction
  }
}

###################################################################################################
###################################################################################################

proc ad_ip_parameter {pname ptype pdefault {phdl true} {properties {}}} {

  if {$pname eq "DEVICE_FAMILY"} {
    add_parameter DEVICE_FAMILY STRING
    set_parameter_property DEVICE_FAMILY SYSTEM_INFO {DEVICE_FAMILY}
    set_parameter_property DEVICE_FAMILY AFFECTS_GENERATION true
    set_parameter_property DEVICE_FAMILY HDL_PARAMETER false
    set_parameter_property DEVICE_FAMILY ENABLED true
  } else {
    add_parameter $pname $ptype $pdefault
    set_parameter_property $pname HDL_PARAMETER $phdl
    set_parameter_property $pname ENABLED true
  }

  foreach {key value} $properties {
    set_parameter_property $pname $key $value
  }
}

###################################################################################################
###################################################################################################

proc adi_add_auto_fpga_spec_params {} {

    source ../scripts/adi_intel_device_info_enc.tcl

    add_parameter AUTO_ASSIGN_PART_INFO BOOLEAN 1
    set_parameter_property AUTO_ASSIGN_PART_INFO DISPLAY_NAME "Automatically populate FPGA Info Parameters"
    set_parameter_property AUTO_ASSIGN_PART_INFO HDL_PARAMETER false
    set_parameter_property AUTO_ASSIGN_PART_INFO GROUP {FPGA info}

    ad_ip_parameter DEVICE STRING "" false {
      SYSTEM_INFO DEVICE
      VISIBLE false
    }

    foreach p $auto_set_param_list {
      adi_add_device_spec_param $p
    }
}

proc adi_add_device_spec_param {param} {

    global auto_set_param_list
    global fpga_technology_list
    global fpga_family_list
    global speed_grade_list
    global dev_package_list
    global xcvr_type_list

    set list_pointer [string tolower $param]
    set list_pointer [append list_pointer "_list"]

    set enc_list [subst $$list_pointer]

    set group "FPGA info"
    set ranges ""

    add_parameter $param INTEGER
    set_parameter_property $param DISPLAY_NAME $param
    set_parameter_property $param GROUP $group
    set_parameter_property $param UNITS None
    set_parameter_property $param HDL_PARAMETER true
    set_parameter_property $param VISIBLE true
    set_parameter_property $param DERIVED true
    set_parameter_property $param DEFAULT_VALUE [lindex $enc_list 0 1]

    add_parameter ${param}_MANUAL INTEGER
    set_parameter_property ${param}_MANUAL DISPLAY_NAME $param
    set_parameter_property ${param}_MANUAL GROUP $group
    set_parameter_property ${param}_MANUAL UNITS None
    set_parameter_property ${param}_MANUAL HDL_PARAMETER false
    set_parameter_property ${param}_MANUAL VISIBLE false
    set_parameter_property ${param}_MANUAL DEFAULT_VALUE [lindex $enc_list 0 1]

    foreach i $enc_list {
     set value [lindex $i 0]
     set encode [lindex $i 1]
     append ranges "\"$encode\:$value\" "
    }
    set_parameter_property $param ALLOWED_RANGES $ranges
    set_parameter_property ${param}_MANUAL ALLOWED_RANGES $ranges
}

proc info_param_validate {} {
  source ../scripts/adi_intel_device_info_enc.tcl
  set auto_populate [get_parameter_value AUTO_ASSIGN_PART_INFO]

  if { $auto_populate == true } {

    set device [get_parameter_value DEVICE]

    set fpga_technology [quartus::device::get_part_info -family $device]
    set fpga_family     [quartus::device::get_part_info -family_variant $device]
    set speed_grade     [quartus::device::get_part_info -speed_grade $device]
    set dev_package     [quartus::device::get_part_info -package $device]
    set xcvr_type       [quartus::device::get_part_info -hssi_speed_grade $device]

    regsub -all "{" $fpga_technology "" fpga_technology
    regsub -all "}" $fpga_technology "" fpga_technology

    regsub "{" $fpga_family "" fpga_family
    regsub "}" $fpga_family "" fpga_family

    regsub "{" $speed_grade "" speed_grade
    regsub "}" $speed_grade "" speed_grade

    regsub "{" $dev_package "" dev_package
    regsub "}" $dev_package "" dev_package

    # fpga_technology
    set matched ""
    foreach i $fpga_technology_list {
        if { [regexp ^[lindex $i 0] $fpga_technology] } {
          set matched [lindex $i 1]
       }
    }
    if { $matched == "" } {
      send_message WARNING "Unknown FPGA_TECHNOLOGY \"$fpga_technology\" form \"$device\" device"
      set_parameter_value FPGA_TECHNOLOGY 0xff
    } else {
      set_parameter_value FPGA_TECHNOLOGY $matched
    }

    # fpga_family
    set matched ""
    foreach i $fpga_family_list {
       if { [regexp ^[lindex $i 0] $fpga_family] } {
          set matched [lindex $i 1]
       }
    }
    if { $matched == "" } {
      send_message WARNING "Unknown FPGA_FAMILY(family variant) \"$fpga_family\" form \"$device\" device"
      set_parameter_value FPGA_FAMILY 0xff
    } else {
      set_parameter_value FPGA_FAMILY $matched
    }

    # speed_grade
    set matched ""
    foreach i $speed_grade_list {
       if { [regexp ^[lindex $i 0] $speed_grade] } {
          set matched [lindex $i 1]
       }
    }
    if { $matched == "" } {
      send_message WARNING "Unknown SPEED_GRADE \"$speed_grade\" form \"$device\" device"
      set_parameter_value SPEED_GRADE 0xff
    } else {
      set_parameter_value SPEED_GRADE $matched
    }

    # dev_package
    set matched ""
    foreach i $dev_package_list {
       if { [regexp ^[lindex $i 0] $dev_package] } {
          set matched [lindex $i 1]
       }
    }
    if { $matched == "" } {
      send_message WARNING "Unknown DEV_PACKAGE \"dev_package\" form \"$device\" device"
      set_parameter_value DEV_PACKAGE 0xff
    } else {
      set_parameter_value DEV_PACKAGE $matched
    }

    # xcvr_type
    set matched ""
    foreach i $xcvr_type_list {
       if { [regexp ^[lindex $i 0] $xcvr_type] } {
          set matched [lindex $i 1]
       }
    }
    set_parameter_value XCVR_TYPE 1 ;#################### fix me

    # if { $matched == "" } {
      # send_message WARNING "Unknown XCVR_TYPE \"xcvr_type\" form \"$device\" device"
      # set_parameter_value XCVR_TYPE 0xff
    # } else {
      # set_parameter_value XCVR_TYPE $matched
    # }
  } else {
   foreach p $auto_set_param_list {
     set_parameter_value $p [get_parameter_value ${p}_MANUAL]
   }
  }

  foreach p $auto_set_param_list {
   set_parameter_property ${p}_MANUAL VISIBLE [expr $auto_populate ? false : true]
   set_parameter_property $p VISIBLE $auto_populate
  }
}

###################################################################################################
###################################################################################################

proc ad_ip_addfile {pname pfile} {

  set pmodule [file tail $pfile]

  regsub {\..$} $pmodule {} mname
  if {$pname eq $mname} {
    add_fileset_file $pmodule VERILOG PATH $pfile TOP_LEVEL_FILE
    return
  }

  set ptype [file extension $pfile]
  if {$ptype eq ".v"} {
    add_fileset_file $pmodule VERILOG PATH $pfile
    return
  }
  if {$ptype eq ".vh"} {
    add_fileset_file $pmodule VERILOG_INCLUDE PATH $pfile
    return
  }
  if {$ptype eq ".sdc"} {
    add_fileset_file $pmodule SDC PATH $pfile
    return
  }
  if {$ptype eq ".tcl"} {
    add_fileset_file $pmodule OTHER PATH $pfile
    return
  }
}

proc ad_ip_files {pname pfiles {pfunction ""}} {

  add_fileset quartus_synth QUARTUS_SYNTH $pfunction ""
  set_fileset_property quartus_synth TOP_LEVEL $pname
  foreach pfile $pfiles {
    ad_ip_addfile $pname $pfile
  }

  add_fileset quartus_sim SIM_VERILOG $pfunction ""
  set_fileset_property quartus_sim TOP_LEVEL $pname
  foreach pfile $pfiles {
    ad_ip_addfile $pname $pfile
  }
}

###################################################################################################
###################################################################################################

proc ad_ip_intf_s_axi {aclk arstn {addr_width 16}} {

  add_interface s_axi_clock clock end
  add_interface_port s_axi_clock ${aclk} clk Input 1

  add_interface s_axi_reset reset end
  set_interface_property s_axi_reset associatedClock s_axi_clock
  add_interface_port s_axi_reset ${arstn} reset_n Input 1

  add_interface s_axi axi4lite end
  set_interface_property s_axi associatedClock s_axi_clock
  set_interface_property s_axi associatedReset s_axi_reset
  add_interface_port s_axi s_axi_awvalid awvalid Input 1
  add_interface_port s_axi s_axi_awaddr awaddr Input $addr_width
  add_interface_port s_axi s_axi_awprot awprot Input 3
  add_interface_port s_axi s_axi_awready awready Output 1
  add_interface_port s_axi s_axi_wvalid wvalid Input 1
  add_interface_port s_axi s_axi_wdata wdata Input 32
  add_interface_port s_axi s_axi_wstrb wstrb Input 4
  add_interface_port s_axi s_axi_wready wready Output 1
  add_interface_port s_axi s_axi_bvalid bvalid Output 1
  add_interface_port s_axi s_axi_bresp bresp Output 2
  add_interface_port s_axi s_axi_bready bready Input 1
  add_interface_port s_axi s_axi_arvalid arvalid Input 1
  add_interface_port s_axi s_axi_araddr araddr Input $addr_width
  add_interface_port s_axi s_axi_arprot arprot Input 3
  add_interface_port s_axi s_axi_arready arready Output 1
  add_interface_port s_axi s_axi_rvalid rvalid Output 1
  add_interface_port s_axi s_axi_rresp rresp Output 2
  add_interface_port s_axi s_axi_rdata rdata Output 32
  add_interface_port s_axi s_axi_rready rready Input 1
}

###################################################################################################
###################################################################################################

proc ad_ip_modfile {ifile ofile flist} {

  global ad_hdl_dir

  set srcfile [open ${ad_hdl_dir}/library/altera/common/${ifile} r]
  set dstfile [open ${ofile} w]

  regsub {\..$} $ifile {} imodule
  regsub {\..$} $ofile {} omodule

  while {[gets $srcfile srcline] >= 0} {
    regsub __${imodule}__ $srcline $omodule dstline
    set index 0
    foreach fword $flist {
      incr index
      regsub __${imodule}_${index}__ $dstline $fword dstline
    }
    puts $dstfile $dstline
  }

  close $srcfile
  close $dstfile

  ad_ip_addfile ad_ip_addfile $ofile
}

###################################################################################################
###################################################################################################

