#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DAEMON_NAME=${SCRIPT_DIR##*/}

kill $(pgrep -f "python $SCRIPT_DIR/$DAEMON_NAME")