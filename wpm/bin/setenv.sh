#!/bin/sh
# set env for CDC

#exportStartHeap

DIRNAME=`dirname $0`

WPM_CLIENT_HOME="$DIRNAME/.."

GLOBAL_SETENV=${INSTALL_DIR}/install/bin/setenv.sh

OLD_JAVA_HOME=$JAVA_HOME
if [ -r "$GLOBAL_SETENV" ]; then
    . "$GLOBAL_SETENV"
fi

if [ "x$JRE_HOME" = "x" ]; then
    JAVA_DIR=$OLD_JAVA_HOME
else
    JAVA_DIR=$JRE_HOME
fi

#exportJavaOpts

JAVA_OPTS="$JAVA_OPTS -Dlog.dir=WPM_CLIENT_HOME/logs"
JAVA_OPTS="$JAVA_OPTS -DtermOutOn=true"
JAVA_OPTS="$JAVA_OPTS -DspoolOn=true"

##==================For more output, change this property to 'DEBUG'==========
JAVA_OPTS="$JAVA_OPTS -DlogLevel=INFO"
##============================================================================

#JAVA_OPTS="$JAVA_OPTS -Xms${DCI_START_HEAP}m"
#JAVA_OPTS="$JAVA_OPTS -Xmx${DCI_MAX_HEAP}m"
#JAVA_OPTS="$JAVA_OPTS -Xss256k"

export JAVA_OPTS

export CLASSPATH