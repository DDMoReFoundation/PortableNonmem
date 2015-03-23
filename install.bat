:: Copyright (c) 2015, Mango Business Solutions Ltd
::
:: Script responsible for preparing portable NONMEM installation

@echo on

set home=%~dp0

call %home%\config.bat

@echo off
call %home%\setup-fortran-compiler.bat

copy nonmem.lic %NM_CD_DIR_NAME%\
if %ERRORLEVEL% NEQ 0 (
	set error_msg="Nonmem license not found"
	goto fail
)

cd %NM_CD_DIR_NAME%
call setUP73 %home%\%NM_CD_DIR_NAME% %home%\%NM_INSTALL_DIR_NAME% gfortran y ar same rec i
cd ..

if %ERRORLEVEL% NEQ 0 (
	set error_msg="Nonmem installation script failed, please refer to its output files for details."
	goto fail
)

:success
	echo "Success"
	echo "Now run post-install.bat"
	goto end

:fail
	echo "Failure"
    echo %error_msg% 
	set ERRORLEVEL=1
:end
