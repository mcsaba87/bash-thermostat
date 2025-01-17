#!/bin/bash

# Minimalistic GCI web interface for bash-thermostat

GOAL_FILE='/tmp/goal_temp'
CURR_FILE='/tmp/curr_temp'

SWITCH_PATH="http://192.168.0.2/api/V4YkafHza8WcEOyCsjdNHo2K2p7EOzjgkQK2bSuh/lights/10"

if [ "$REQUEST_METHOD" = "POST" ]; 
then
    if [ "$CONTENT_LENGTH" -gt 0 ]; 
    then
	    in_raw="$(cat)"
	    goal=`echo $in_raw | tr '&' '\n' | grep goal | awk -F '=' '{ print $2 }'`
	    echo $goal > $GOAL_FILE
    fi 
fi

function get_heating_state {
        wget -O - -q  "${SWITCH_PATH}" | awk -F '[",:]' '{ print $7  }'
}


echo "HTTP/1.1 200 OK"
echo 'Link: </favicon.ico>; rel="icon"'
echo "Date: $(TZ=UTC; date '+%a, %d %b %Y %T GMT')"
  
cat << EOF
Content-Type: text/html

<html>
<title>Thermostat</title>
<body>	
<h1>Thermostat</h1>
<form method=post>
Set goal temp: <input type=text name=goal/>centi Celsius (for 20C type 2000)<br>
<input type=submit />
</form>
<br>
EOF

echo "current values:<br>"
echo "current temperature:`cat $CURR_FILE` centi Celsius <br> goal temperature: `cat $GOAL_FILE` centi Celsius <br>"
echo "heating state: `get_heating_state`" 
cat << EOF
</body>
</html>
EOF

