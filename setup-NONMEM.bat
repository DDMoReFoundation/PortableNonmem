:: Copyright (c) 2015, Mango Business Solutions Ltd
:: The script sets up environment for NONMEM execution execution
:: Credits
:: The script is based on setup scripts from PKPDStick_72 developed by (c) Andrew C. Hooker 2014

@echo off

set home=%~dp0
set nm_install_dir="nm_7.3.0_g"

CALL %home%\setup-perl.bat

CALL %home%\setup-fortran-compiler.bat

set PATH=%home%\%nm_install_dir%\run;%PATH%

CALL perl %home%\setup-NONMEM.pl %home% %nm_install_dir%

