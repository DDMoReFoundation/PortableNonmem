@echo off

set home=%~dp0

rem  This redirects existing path entries so as not to conflict with those of the SEE bundled version of NONMEM, FORTRAN and R
set PATH=%PATH:g77\bin=g77\foo%
set PATH=%PATH:gfortran=gfortran-foo%
set PATH=%PATH:nmvi=nmvi-foo%
set PATH=%PATH:IA32=IA32-foo%
set PATH=%PATH:Intel=Intel-foo%
set PATH=%PATH:g95=g95-foo%

set PATH=%home%\gfortran\libexec\gcc\i586-pc-mingw32\4.6.0;%home%\gfortran\bin;%PATH%


