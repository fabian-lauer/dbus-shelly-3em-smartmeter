#!/bin/bash

rm /service/dbus-shelly-3em-smartmeter
kill $(pgrep -f 'supervise dbus-shelly-3em-smartmeter')
chmod a-x /data/dbus-shelly-3em-smartmeter/service/run
./restart.sh
