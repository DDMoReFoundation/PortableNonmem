:: Copyright (c) 2015, Mango Business Solutions Ltd
::
:: Script responsible for preparing portable NONMEM installation. 
:: Performs additional steps following NONMEM setup script.

@echo off

set home=%~dp0

CALL %home%\config.bat

COPY %home%\nmhelp.bat %home%\%NM_INSTALL_DIR_NAME%\nmhelp.bat.orig
if %ERRORLEVEL% NEQ 0 (
    echo "Failure: Could not copy nmhelp.bat script"
    exit 1
)

COPY %home%\%NM_INSTALL_DIR_NAME%\run\%NMFE_BIN% %home%\%NM_INSTALL_DIR_NAME%\run\%NMFE_BIN%.orig
if %ERRORLEVEL% NEQ 0 (
    echo "Failure: Could not archive the %NMFE_BIN% file"
    exit 1
)


echo "Success"


echo "Now run test.bat"