#!/bin/sh
#  env for wpm

DIRNAME=`dirname $0`
INSTALL_DIR=$DIRNAME/../../..

. "$DIRNAME/setenv.sh"

if [ -x "${JRE_HOME}/bin/java" ]; then
    JAVA_EXE="${JRE_HOME}/bin/java"
else
	if [ -x "${JAVA_HOME}/bin/java" ]; then
		JAVA_EXE="${JAVA_HOME}/bin/java"
	else
		JAVA_EXE="java"
	fi
fi

RUN=${JAVA_EXE}

CLASSPATH=$CLASSPATH:$WPM_CLIENT_HOME/lib/commons-cli.jar
CLASSPATH=$CLASSPATH:$WPM_CLIENT_HOME/lib/commons-io.jar
CLASSPATH=$CLASSPATH:$WPM_CLIENT_HOME/lib/commons-lang3.jar
CLASSPATH=$CLASSPATH:$WPM_CLIENT_HOME/lib/gf.jakarta.mail.jar
CLASSPATH=$CLASSPATH:$WPM_CLIENT_HOME/lib/gf.webservices-api-osgi.jar
CLASSPATH=$CLASSPATH:$WPM_CLIENT_HOME/lib/httpcore.jar
CLASSPATH=$CLASSPATH:$WPM_CLIENT_HOME/lib/is-client.jar
CLASSPATH=$CLASSPATH:$WPM_CLIENT_HOME/lib/is-wpm-client.jar
CLASSPATH=$CLASSPATH:$WPM_CLIENT_HOME/lib/is-wpm-core.jar
CLASSPATH=$CLASSPATH:$WPM_CLIENT_HOME/lib/jackson-annotations.jar
CLASSPATH=$CLASSPATH:$WPM_CLIENT_HOME/lib/jackson-core.jar
CLASSPATH=$CLASSPATH:$WPM_CLIENT_HOME/lib/jackson-databind.jar
CLASSPATH=$CLASSPATH:$WPM_CLIENT_HOME/lib/jgit.jar
CLASSPATH=$CLASSPATH:$WPM_CLIENT_HOME/lib/jgit-ssh-apache.jar
CLASSPATH=$CLASSPATH:$WPM_CLIENT_HOME/lib/mina-core.jar
CLASSPATH=$CLASSPATH:$WPM_CLIENT_HOME/lib/slf4j-api.jar
CLASSPATH=$CLASSPATH:$WPM_CLIENT_HOME/lib/slf4j-nop.jar
CLASSPATH=$CLASSPATH:$WPM_CLIENT_HOME/lib/snakeyaml.jar
CLASSPATH=$CLASSPATH:$WPM_CLIENT_HOME/lib/sshd-common.jar
CLASSPATH=$CLASSPATH:$WPM_CLIENT_HOME/lib/sshd-core.jar
CLASSPATH=$CLASSPATH:$WPM_CLIENT_HOME/lib/sshd-mina.jar

$RUN $JAVA_OPTS com.softwareag.is.wpm.cli.Main "$@"

exitStatus=$?

exit $exitStatus