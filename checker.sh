#!/bin/bash

pname=`basename $0 .sh`

walgreensapi='https://www.walgreens.com/hcschedulersvc/svc/v1/immunizationLocations/availability'
if [ `uname -s` == 'Darwin' ]; then
    currentdate=`date "+%Y-%m-%d"`
else
    currentdate=`date --rfc-3339=date`
fi
coordinates='37.7030051 -85.8647201
36.972813 -86.4549821
37.2821868 -85.9171529
38.1558676 -85.695275'

echo "$coordinates" |
	while read line; do
		if [ -z "$line" ]; then
			continue
		fi

		tmpfile=$(mktemp /tmp/$pname.XXXXXX)

		lat=`echo $line | cut -d' ' -f1`
		long=`echo $line | cut -d' ' -f2`

		payload='{ "serviceId": "99", "position": { "latitude": '$lat', "longitude": '$long' }, "appointmentAvailability":{"startDateTime": "'$currentdate'"},"radius": 25}'

		curl -sS -X POST $walgreensapi -H 'Content-Type: application/json' -d "$payload" -o $tmpfile
		cat "$tmpfile"|json_pp
		rm "$tmpfile"
	done

