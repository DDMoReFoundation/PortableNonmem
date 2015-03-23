:: Copyright (c) 2015, Mango Business Solutions Ltd
::
:: Script responsible for preparing SEE bundle for SEE. 

@echo off

set home=%~dp0

call %home%\config.bat

echo "Clean up"
if EXIST "%SEE_BUNDLE_DIR%" (
    rmdir /s/q %SEE_BUNDLE_DIR%
)
mkdir %SEE_BUNDLE_DIR%


echo "Copying Nonmem installation directory"
XCOPY %NM_INSTALL_DIR_NAME% %SEE_BUNDLE_DIR%\%NM_INSTALL_DIR_NAME%\ /e/s/q
if %ERRORLEVEL% NEQ 0 (
    set error_msg="Could not copy Nonmem installation to SEE bundle directory"
	goto fail
)
del %SEE_BUNDLE_DIR%\%NM_INSTALL_DIR_NAME%\license\nonmem.lic

echo "Copying Nonmem portable dependencies (compiler, perl installation)"
XCOPY gfortran %SEE_BUNDLE_DIR%\gfortran\ /e/s/q
if %ERRORLEVEL% NEQ 0 (
    set error_msg="Could not fortran compiler to SEE bundle directory"
	goto fail
)

XCOPY perl %SEE_BUNDLE_DIR%\perl\ /e/s/q
if %ERRORLEVEL% NEQ 0 (
    set error_msg="Could not copy Perl to SEE bundle directory"
	goto fail
)

echo "Copying Nonmem environment setup scripts"
copy setup-fortran-compiler.bat %SEE_BUNDLE_DIR%\
if %ERRORLEVEL% NEQ 0 (
    set error_msg="Failure: Could not copy setup-fortran-compiler.bat to SEE bundle directory"
	goto fail
)

copy setup-NONMEM.bat %SEE_BUNDLE_DIR%\
if %ERRORLEVEL% NEQ 0 (
    set error_msg="Could not setup-NONMEM.bat to SEE bundle directory"
	goto fail
)

copy setup-NONMEM.pl %SEE_BUNDLE_DIR%\
if %ERRORLEVEL% NEQ 0 (
    set error_msg="Could not copy setup-NONMEM.pl to SEE bundle directory"
	goto fail
)

copy setup-perl.bat %SEE_BUNDLE_DIR%\
if %ERRORLEVEL% NEQ 0 (
    set error_msg="Could not copy setup-perl.bat to SEE bundle directory"
	goto fail
)


:success
	echo "Success"
	goto end

:fail
	echo "Failure"
    echo %error_msg% 
	set ERRORLEVEL=1
:end
