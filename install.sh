#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SERVICE_NAME=$(basename $SCRIPT_DIR)
rclocalname=/data/rc.local

if [ ! -f $SCRIPT_DIR/config.ini ]; then
    echo "config.ini file not found. Please make sure it exists. If not created yet, please copy it from config.example."
    exit 1
fi

if [ -f $SCRIPT_DIR/current.log ]; then
    rm $SCRIPT_DIR/current.log*
fi

# set permissions for script files
chmod a+x $SCRIPT_DIR/install.sh
chmod 744 $SCRIPT_DIR/install.sh

chmod a+x $SCRIPT_DIR/restart.sh
chmod 744 $SCRIPT_DIR/restart.sh

chmod a+x $SCRIPT_DIR/uninstall.sh
chmod 744 $SCRIPT_DIR/uninstall.sh

chmod a+x $SCRIPT_DIR/service/run
chmod 755 $SCRIPT_DIR/service/run

chmod a+x $SCRIPT_DIR/service/log/run
chmod 755 $SCRIPT_DIR/service/log/run

# create sym-link to run script in deamon
ln -s $SCRIPT_DIR/service /service/$SERVICE_NAME
# add install-script to rc.local to be ready for firmware update


if [ ! -f $rclocalname ]
then
    touch $rclocalname
    chmod 755 $rclocalname
    echo "#!/bin/bash" >> $rclocalname
    echo >> $rclocalname
fi

grep -qxF "/bin/bash $SCRIPT_DIR/install.sh" $rclocalname || echo "/bin/bash $SCRIPT_DIR/install.sh" >> $rclocalname
