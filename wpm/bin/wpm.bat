@echo off

setlocal


set DIRNAME=%~dp0
set INSTALL_DIR=%DIRNAME%..\..\..\..\..\..\..\
set ENV_PATH=%DIRNAME%\setenv.bat
call "%ENV_PATH%"

if "%JAVA_HOME%" == "" goto noJavaHome

:runJava

set RUN="%JAVA_HOME%\bin\java"

:setClassPath
set CLASSPATH=%CLASSPATH%;%WPM_CLIENT_HOME%\lib\commons-cli.jar
set CLASSPATH=%CLASSPATH%;%WPM_CLIENT_HOME%\lib\commons-io.jar
set CLASSPATH=%CLASSPATH%;%WPM_CLIENT_HOME%\lib\commons-lang3.jar
set CLASSPATH=%CLASSPATH%;%WPM_CLIENT_HOME%\lib\gf.jakarta.mail.jar
set CLASSPATH=%CLASSPATH%;%WPM_CLIENT_HOME%\lib\gf.webservices-api-osgi.jar
set CLASSPATH=%CLASSPATH%;%WPM_CLIENT_HOME%\lib\httpcore.jar
set CLASSPATH=%CLASSPATH%;%WPM_CLIENT_HOME%\lib\is-client.jar
set CLASSPATH=%CLASSPATH%;%WPM_CLIENT_HOME%\lib\is-wpm-client.jar
set CLASSPATH=%CLASSPATH%;%WPM_CLIENT_HOME%\lib\is-wpm-core.jar
set CLASSPATH=%CLASSPATH%;%WPM_CLIENT_HOME%\lib\jackson-annotations.jar
set CLASSPATH=%CLASSPATH%;%WPM_CLIENT_HOME%\lib\jackson-core.jar
set CLASSPATH=%CLASSPATH%;%WPM_CLIENT_HOME%\lib\jackson-databind.jar
set CLASSPATH=%CLASSPATH%;%WPM_CLIENT_HOME%\lib\jgit.jar
set CLASSPATH=%CLASSPATH%;%WPM_CLIENT_HOME%\lib\jgit-ssh-apache.jar
set CLASSPATH=%CLASSPATH%;%WPM_CLIENT_HOME%\lib\mina-core.jar
set CLASSPATH=%CLASSPATH%;%WPM_CLIENT_HOME%\lib\slf4j-api.jar
set CLASSPATH=%CLASSPATH%;%WPM_CLIENT_HOME%\lib\slf4j-nop.jar
set CLASSPATH=%CLASSPATH%;%WPM_CLIENT_HOME%\lib\snakeyaml.jar
set CLASSPATH=%CLASSPATH%;%WPM_CLIENT_HOME%\lib\sshd-common.jar
set CLASSPATH=%CLASSPATH%;%WPM_CLIENT_HOME%\lib\sshd-core.jar
set CLASSPATH=%CLASSPATH%;%WPM_CLIENT_HOME%\lib\sshd-mina.jar
set CLASSPATH=%CLASSPATH%;%WPM_CLIENT_HOME%\wpm.yml

%RUN% %JAVA_OPTS% com.softwareag.is.wpm.cli.Main %*

goto end

rem ========ERROR STATES========

:noJavaHome
echo The environment variable JAVA_HOME must be set.
echo Can't run wpm.
goto end

:end
endlocal

set returnValue=%ERRORLEVEL%
IF %returnValue% NEQ 0 exit /b %returnValue%
@echo off