#!/bin/bash

SWITCH_DIFF="50";
GOAL_TEMP="2150";
CURR_TEMP="2000";
DELAY="30";
HEATING="false";

# Holds the most recently read temperature value.
CURR_FILE="/tmp/curr_temp";
# You can change the goal temperature in this file without restarting the process.
GOAL_FILE="/tmp/goal_temp";

# Put the IP and api path of your HUE bridge here. See HUE documentation for details.
SENSOR_PATH="http://192.168.0.2/api/V4YkafHza8WcEOyCsjdNHo2K2p7EOzjgkQK2bSuh/sensors/4"
SWITCH_PATH="http://192.168.0.2/api/V4YkafHza8WcEOyCsjdNHo2K2p7EOzjgkQK2bSuh/lights/10"

function get_temperature {
	wget -O - -q "${SENSOR_PATH}/4" | awk -F '[\":,]' '{ print $7  }';
}

function heating_on {
	echo -e "\n`date` - Heating ON at $CURR_TEMP C";
	wget --method=PUT --body-data="{\"on\":true}" -O - -q "${SWITCH_PATH}/state"
	echo "";
}

function heating_off {
	echo -e "\n`date` - Heating OFF at $CURR_TEMP C";
	wget --method=PUT --body-data="{\"on\":false}" -O - -q "${SWITCH_PATH}/state"
	echo "";
}

function get_heating_state {
	wget -O - -q  "${SWITCH_PATH}" | awk -F '[",:]' '{ print $7  }'
}


while [ true ]
do	

	GOAL_TEMP=`cat $GOAL_FILE`
	CURR_TEMP=`get_temperature`;
	HEATING=`get_heating_state`;
	
	if [ "$HEATING" == "true" ];
	then
		if [ "$CURR_TEMP" -ge "$GOAL_TEMP" ]
		then
			heating_off;
			HEATING="false";
		fi
	else
		if [ "$CURR_TEMP" -le $(($GOAL_TEMP - $SWITCH_DIFF)) ]
		then
			heating_on;
			HEATING="true";
		fi
	fi
	
	echo $CURR_TEMP > $CURR_FILE;

	echo -n "."
	sleep $DELAY;	
done
