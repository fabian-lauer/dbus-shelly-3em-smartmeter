#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}"  )" &> /dev/null && pwd  )
DAEMON_NAME=${SCRIPT_DIR##*/}
rclocalname=/data/rc.local

if [[ -L "/service/$DAEMON_NAME" && -d "/service/$DAEMON_NAME" ]]
then
  rm /service/$DAEMON_NAME
fi

python_pid=$(pgrep -f "python ${SCRIPT_DIR}")
supervise_pid=$(pgrep -f "supervise ${DAEMON_NAME}")

[ ! -z $python_pid ] && kill $python_pid
[ ! -z $supervise_pid ] && kill $supervise_pid

grep -qxF "/bin/bash $SCRIPT_DIR/install.sh" $rclocalname && sed -i "\|/bin/bash ${SCRIPT_DIR}/install.sh|d" $rclocalname
[ -d "${SCRIPT_DIR}/service/supervise" ] && rm -rf "${SCRIPT_DIR}/service/supervise"
[ -d "${SCRIPT_DIR}/service/log/supervise" ] && rm -rf "${SCRIPT_DIR}/service/log/supervise"

