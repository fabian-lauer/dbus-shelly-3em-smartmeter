#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}"  )" &> /dev/null && pwd  )
DAEMON_NAME=${SCRIPT_DIR##*/}

# set permissions for script files
chmod a+x $SCRIPT_DIR/restart.sh
chmod 744 $SCRIPT_DIR/restart.sh

chmod a+x $SCRIPT_DIR/uninstall.sh
chmod 744 $SCRIPT_DIR/uninstall.sh

chmod a+x $SCRIPT_DIR/service/run
chmod 755 $SCRIPT_DIR/service/run



# create sym-link to run script in deamon
ln -s $SCRIPT_DIR/service /service/$DAEMON_NAME



# add install-script to rc.local to be ready for firmware update
filename=/data/rc.local
if [ ! -f $filename ]
then
    touch $filename
    chmod 755 $filename
    echo "#!/bin/bash" >> $filename
    echo >> $filename
fi

grep -qxF "$SCRIPT_DIR/install.sh" $filename || echo "$SCRIPT_DIR/install.sh" >> $filename
