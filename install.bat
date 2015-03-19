:: Copyright (c) 2015, Mango Business Solutions Ltd
::
:: Script responsible for preparing portable NONMEM installation

@echo on

set home=%~dp0

CALL %home%\config.bat

@echo off
CALL %home%\setup-fortran-compiler.bat

COPY nonmem.lic %NM_CD_DIR_NAME%\

if %ERRORLEVEL% NEQ 0 (
    echo "Failure: Nonmem license not found"
    exit 1
)

CD %NM_CD_DIR_NAME%

CALL SETUP73 %home%\%NM_CD_DIR_NAME% %home%\%NM_INSTALL_DIR_NAME% gfortran y ar same rec i

if %ERRORLEVEL% NEQ 0 (
    echo "Failure: Nonmem installation script failed, please refer to its output files for details."
    exit 1
)

CD ..

echo "Success"

echo "Now run post-install.bat"

