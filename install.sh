#!/bin/bash

# set permissions for script files
chmod a+x /data/dbus-shelly-3em-smartmeter/restart.sh
chmod 744 /data/dbus-shelly-3em-smartmeter/restart.sh

chmod a+x /data/dbus-shelly-3em-smartmeter/uninstall.sh
chmod 744 /data/dbus-shelly-3em-smartmeter/uninstall.sh

chmod a+x /data/dbus-shelly-3em-smartmeter/service/run
chmod 755 /data/dbus-shelly-3em-smartmeter/service/run



# create sym-link to run script in deamon
ln -s /data/dbus-shelly-3em-smartmeter/service /service/dbus-shelly-3em-smartmeter



# add install-script to rc.local to be ready for firmware update
filename=/data/rc.local
if [ ! -f $filename ]
then
    touch $filename
    chmod 755 $filename
    echo "#!/bin/bash" >> $filename
    echo >> $filename
fi

grep -qxF '/data/dbus-shelly-3em-smartmeter/install.sh' $filename || echo '/data/dbus-shelly-3em-smartmeter/install.sh' >> $filename
