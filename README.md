# dbus-shelly-3em-smartmeter
Integrate Shelly 3EM smart meter into Victron Energies Venus OS

## Purpose
With the scripts in this repro it should be easy possible to install, uninstall, restart a service that connects the Shelly 3EM to the VenusOS and GX devices from Victron.
Idea is pasend on @RalfZim project linked below

## Inspiration
This project is my first on GitHub and with the Victron Venus OS, so I took some ideas and approaches from the following projects - many thanks for sharing the knowledge:
- https://github.com/RalfZim/venus.dbus-fronius-smartmeter
- https://github.com/victronenergy/dbus-smappee
- https://github.com/Louisvdw/dbus-serialbattery
- https://community.victronenergy.com/questions/85564/eastron-sdm630-modbus-energy-meter-community-editi.html


## How it works

## Install
Just grap a copy of the main branche and copy them to /data/dbus-shelly-3em-smartmeter.
After that call the install.sh script.

The following script should do everything for you:
```
wget https://github.com/fabian-lauer/dbus-shelly-3em-smartmeter/archive/refs/heads/main.zip
mkdir /data/dbus-shelly-3em-smartmeter
unzip main.zip "dbus-shelly-3em-smartmeter-main/*" -d /data/dbus-shelly-3em-smartmeter
chmod a+x /data/dbus-shelly-3em-smartmeter/install.sh
/data/dbus-shelly-3em-smartmeter/install.sh
rm main.zip
```

## Configuration
Within the project there is a file 'config.ini' - just change the values - most important is the host, username and password in section "ONPREMISE".
The "DEFAULT" section is not used / has no alternatives at the moment.

## Used documentation
- https://github.com/victronenergy/venus/wiki/dbus#grid   DBus paths for Victron namespace
- https://www.victronenergy.com/live/ccgx:root_access   How to get root access on GX device/Venus OS
