## ###############################################################################################
## adi_device_info_enc.tcl
## ###############################################################################################

variable auto_set_param_list
variable fpga_series_list
variable fpga_family_list
variable speed_grade_list
variable dev_package_list
variable xcvr_type_list

# Parameter list for automatic assignament
set auto_set_param_list {
          XCVR_TYPE \
          DEV_PACKAGE \
          SPEED_GRADE \
          FPGA_FAMILY \
          FPGA_TECHNOLOGY}


# List for automatically assigned parameter values and encoded values
# The list name must be the parameter name (lowercase), appending "_list" to it
set fpga_technology_list { \
        { 7series     0 } \
        { ultrascale  1 } \
        { ultrascale+ 2 }}

set fpga_family_list { \
        { artix  0 } \
        { kintex 1 } \
        { virtex 2 } \
        { zynq   3 }}

set speed_grade_list { \
        { -1   10 } \
        { -1L  11 } \
        { -1H  12 } \
        { -1HV 13 } \
        { -1LV 14 } \
        { -2   20 } \
        { -2L  21 } \
        { -2LV 22 } \
        { -3   30 }}

set dev_package_list { \
        { rf 1  } \
        { fl 2  } \
        { ff 3  } \
        { fb 4  } \
        { hc 5  } \
        { fh 6  } \
        { cs 7  } \
        { cp 8  } \
        { ft 9  } \
        { fg 10 } \
        { sb 11 } \
        { rb 12 } \
        { rs 13 } \
        { cl 14 } \
        { sf 15 } \
        { ba 16 } \
        { fa 17 }}

set xcvr_type_list { \
        { GTPE2_NOT_SUPPORTED 1 } \
        { GTXE2               2 } \
        { GTHE2_NOT_SUPPORTED 3 } \
        { GTZE2_NOT_SUPPORTED 4 } \
        { GTHE3               5 } \
        { GTYE3_NOT_SUPPORTED 6 } \
        { GTRE4_NOT_SUPPORTED 7 } \
        { GTHE4               8 } \
        { GTYE4_NOT_SUPPORTED 9 } \
        { GTME4_NOT_SUPPORTED 10}}

## ###############################################################################################
## ###############################################################################################
