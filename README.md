# dbus-shelly-3em-smartmeter
Integrate Shelly 3EM and Shelly Pro 3EM smart meters into [Victron Energies Venus OS](https://github.com/victronenergy/venus)

## Purpose
With the scripts in this repo it should be easy possible to install, uninstall, restart a service that connects the Shelly 3EM to the VenusOS and GX devices from Victron.
Idea is pasend on @RalfZim project linked below.



## Inspiration
This project is my first on GitHub and with the Victron Venus OS, so I took some ideas and approaches from the following projects - many thanks for sharing the knowledge:
- https://github.com/RalfZim/venus.dbus-fronius-smartmeter
- https://github.com/victronenergy/dbus-smappee
- https://github.com/Louisvdw/dbus-serialbattery
- https://community.victronenergy.com/idea/114716/power-meter-lib-for-modbus-rtu-based-meters-from-a.html - [Old Thread](https://community.victronenergy.com/questions/85564/eastron-sdm630-modbus-energy-meter-community-editi.html)

## How it works
### My setup
- Shelly 3EM with latest firmware (20220209-094824/v1.11.8-g8c7bb8d)
  - 3-Phase installation (normal for Germany)
  - Connected to Wifi network "A"
  - IP 192.168.2.13/24  
- Victron Energy Cerbo GX with Venus OS - Firmware v2.93
  - No other devices from Victron connected (still waiting for shipment of Multiplus-2)
  - Connected to Wifi network "A"
  - IP 192.168.2.20/24

### Details / Process
As mentioned above the script is inspired by @RalfZim fronius smartmeter implementation.
So what is the script doing:
- Running as a service
- connecting to DBus of the Venus OS `com.victronenergy.grid.http_40` or `com.victronenergy.pvinverter.http_40`
- In `legacy` mode, measurements and serial/MAC come from `/status`. A sample response is [here](docs/shelly3em-status-sample.json).
- In `rpc` mode, serial/MAC is obtained once during initialization from `/rpc/Shelly.GetDeviceInfo`; measurements come from `/rpc/Shelly.GetStatus` (`em:0` and `emdata:0`).
- Paths are added to the DBus with default value 0 - including some settings like name, etc
- After that a "loop" is started which pulls Shelly 3EM data every 500ms from the REST-API and updates the values in the DBus

Thats it 😄

### Pictures
![Tile Overview](img/venus-os-tile-overview.PNG)
![Remote Console - Overview](img/venus-os-remote-console-overview.PNG) 
![SmartMeter - Values](img/venus-os-shelly3em-smartmeter.PNG)
![SmartMeter - Device Details](img/venus-os-shelly3em-smartmeter-devicedetails.PNG)




## Install & Configuration
### Get the code
Just grap a copy of the main branche and copy them to `/data/dbus-shelly-3em-smartmeter`.
After that call the install.sh script.

The following script should do everything for you:
```
wget https://github.com/fabian-lauer/dbus-shelly-3em-smartmeter/archive/refs/heads/main.zip
unzip main.zip "dbus-shelly-3em-smartmeter-main/*" -d /data
mv /data/dbus-shelly-3em-smartmeter-main /data/dbus-shelly-3em-smartmeter
chmod a+x /data/dbus-shelly-3em-smartmeter/install.sh
/data/dbus-shelly-3em-smartmeter/install.sh
rm main.zip
```
⚠️ Check configuration after that - because service is already installed an running and with wrong connection data (host, username, pwd) you will spam the log-file

### Change config.ini
Within the project there is a file `/data/dbus-shelly-3em-smartmeter/config.ini` - just change the values - most important is the host, username and password in section "ONPREMISE". More details below:

| Section  | Config vlaue | Explanation |
| ------------- | ------------- | ------------- |
| DEFAULT  | AccessType | Fixed value 'OnPremise' |
| DEFAULT  | SignOfLifeLog  | Time in minutes how often a status is added to the log-file `current.log` with log-level INFO |
| DEFAULT  | CustomName  | Name of your device - usefull if you want to run multiple versions of the script |
| DEFAULT  | DeviceInstance  | DeviceInstanceNumber e.g. 40 |
| DEFAULT  | Role | use 'grid' or 'pvinverter' to set the type of the shelly 3EM |
| DEFAULT  | Position | Available Postions: 0 = AC, 1 = AC-Out 1, AC-Out 2 |
| DEFAULT  | LogLevel  | Define the level of logging - lookup: https://docs.python.org/3/library/logging.html#levels |
| ONPREMISE  | ApiMode | `legacy` (Gen1 `/status`, default when omitted) or `rpc` (Pro 3EM); case-insensitive. Other values are rejected. |
| ONPREMISE  | Host | IP or hostname of on-premise Shelly 3EM web-interface |
| ONPREMISE  | Username | HTTP Basic username for Gen1; `admin` for authenticated RPC. Leave blank when authentication is disabled |
| ONPREMISE  | Password | Device password; leave blank when authentication is disabled |
| ONPREMISE  | L1Position | Which input on the Shelly in 3-phase grid is supplying a single Multi |


### Shelly Pro 3EM example

Use the following `config.ini`, replacing `192.168.2.13` with your meter's IP address:

```ini
[DEFAULT]
AccessType = OnPremise
SignOfLifeLog = 1
CustomName = Shelly Pro 3EM
DeviceInstance = 40
Role = grid
Position = 0
LogLevel = ERROR

[ONPREMISE]
ApiMode = rpc
Host = 192.168.2.13
Username =
Password =
L1Position = 1
```

If device authentication is enabled, set `Username = admin` and `Password = your-device-password`.
RPC uses HTTP Digest (SHA-256 challenge/response), as described in the
[official Shelly authentication documentation](https://shelly-api-docs.shelly.cloud/gen2/General/Authentication/).
Gen1 continues to use HTTP Basic authentication. Credentials are not embedded in request URLs.
Restart the service after changing configuration: `/data/dbus-shelly-3em-smartmeter/restart.sh`.

For an original Gen1 3EM, use `ApiMode = legacy` (or omit it), with your existing credentials.
RPC support requires the three-phase `em:0` and `emdata:0` components, such as the Pro 3EM in its three-phase profile.
Single-phase EM1/EM1Data layouts are unsupported and produce a clear error.

A/B/C initially map to L1/L2/L3. Phase remapping moves voltage, current, signed power,
and both energy counters together. Positive power is import; negative power is export.
Forward and reverse energy remain independent cumulative counters. Both APIs supply Wh;
D-Bus publishes kWh, with total energy equal to the sum of the phase counters on every
successful poll, including at zero power. This replaces the previous total-energy integration
from instantaneous power, so existing installations may see total energy change to the meter's lifetime counters.

HTTP/authentication failures, timeouts, malformed JSON, RPC errors and missing/null or invalid
required readings are logged as failures. No partial reading is published. The existing
failure fallback sets power paths to zero, retains the previous energy counters and marks
`/Connected = 0`; polling continues and the next valid reading restores `/Connected = 1`.
Initialization requires a valid device MAC; startup failures are logged and the installed
service supervisor retries the process.

### Remapping L1
In a 3-phase grid with a single Multi, Venus OS expects L1 to be supplying the only Multi. This is not always the case. If for example your Multi is supplied by L3 (Input `C` on the Shelly) your GX device will show AC Loads as consuming from both L1 and L3. Setting `L1Position` to the appropriate Shelly input allows for remapping the phases and showing correct data on the GX device.

If your single Multi is connected to the Input `A` on the Shelly you don't need to change this setting. Setting `L1Position` to `2` would swap the `B` CT & Voltage sensors data on the Shelly with the `A` CT & Voltage sensors data on the Shelly. Respectively, setting `L1Position` to `3` would swap `A` and `C` inputs.

## Used documentation
- https://github.com/victronenergy/venus/wiki/dbus#grid   DBus paths for Victron namespace GRID
- https://github.com/victronenergy/venus/wiki/dbus#pv-inverters   DBus paths for Victron namespace PVINVERTER
- https://github.com/victronenergy/venus/wiki/dbus-api   DBus API from Victron
- https://www.victronenergy.com/live/ccgx:root_access   How to get root access on GX device/Venus OS

## Discussions on the web
This module/repository has been posted on the following threads:
- https://community.victronenergy.com/questions/125793/shelly-3em-smartmeter-with-venusos-cerbo-gx.html
