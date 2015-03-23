:: Copyright (c) 2015, Mango Business Solutions Ltd
::
:: Script responsible for preparing portable NONMEM installation. 
:: Performs additional steps following NONMEM setup script.

@echo off

set home=%~dp0

call %home%\config.bat

copy %home%\nmhelp.bat %home%\%NM_INSTALL_DIR_NAME%\nmhelp.bat.orig
if %ERRORLEVEL% NEQ 0 (
    set error_msg="Could not copy nmhelp.bat script"
	goto fail
)

copy %home%\%NM_INSTALL_DIR_NAME%\run\%NMFE_BIN% %home%\%NM_INSTALL_DIR_NAME%\run\%NMFE_BIN%.orig
if %ERRORLEVEL% NEQ 0 (
    set error_msg="Could not archive the %NMFE_BIN% file"
	goto fail
)

:success
	echo "Success"
	echo "Now run test.bat"
	goto end

:fail
	echo "Failure"
    echo %error_msg% 
	set ERRORLEVEL=1
:end