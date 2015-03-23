:: Copyright (c) 2015, Mango Business Solutions Ltd
::
:: Installer configuration

:: Avoiding bogus failures due to some previous script failing
@echo off
set ERRORLEVEL=0

@echo on
:: Update these properties accordingly to the version of NONMEM that you install
:: Name of the Nonmem install CD directory
set NM_CD_DIR_NAME="nm730CD"
:: Name of the target Nonmem install directory
set NM_INSTALL_DIR_NAME="nm_7.3.0_g"
:: Name of the Nonmem nmfe batch file (Refer to Nonmem User Guide) 
set NMFE_BIN="nmfe73.bat"

:: location of the target SEE bundle directory
set SEE_BUNDLE_DIR=%home%\NONMEM_SEE

@echo off

