#!/bin/sh /etc/rc.common

convert_this_sections_X_to_Y_callback() {
    # run commands for every X section
    local cfg="$1"
    local uciconfigfam="$2"
    local renamefrom="$3"
    local renameto="$4"
    local value

	config_get value "$cfg" $renamefrom
	if [ -n "$value" ] ; then
		uci delete $uciconfigfam."$cfg"."$renamefrom"
		# echo delete $uciconfigfam."$cfg"."$renamefrom"
	else
		return 0
	fi

	# Bug: config_get only gets pre-commit values
	# config_get value2 "$cfg" $renameto

	# Just in case renameto target exists (e.g. host entries)
	value2=`uci -q get $uciconfigfam."$cfg"."$renameto"`
	if [ -n "$value2" ] ; then
		value2=${value2% *} #trim prefixed whitespace
		value2=${value2# *} #trim suffixed whitespace
		# echo delete $uciconfigfam."$cfg"."$renameto"
		uci delete $uciconfigfam."$cfg"."$renameto"
	fi

	uci set $uciconfigfam."$cfg".$renameto="$value $value2"
	# echo set $uciconfigfam."$cfg".$renameto="$value $value2"
}

uciconfig=dhcp

config_load $uciconfig
# tag entries
config_foreach convert_this_sections_X_to_Y_callback tag $uciconfig tag match_tag
# dhcp entries
config_foreach convert_this_sections_X_to_Y_callback dhcp $uciconfig tag match_tags
# host entries
config_foreach convert_this_sections_X_to_Y_callback host $uciconfig match_tag match_tags
config_foreach convert_this_sections_X_to_Y_callback host $uciconfig networkid set_tags
config_foreach convert_this_sections_X_to_Y_callback host $uciconfig tag set_tags
# boot entries
config_foreach convert_this_sections_X_to_Y_callback boot $uciconfig networkid match_tag
# set_tag for each of dhcp mac vendorclass userclass circuitid remoteid subscrid match
for class in dhcp mac vendorclass userclass circuitid remoteid subscrid match; do
	config_foreach convert_this_sections_X_to_Y_callback $class $uciconfig networkid set_tag
done

# uci commit $uciconfig
uci show $uciconfig
exit 0
