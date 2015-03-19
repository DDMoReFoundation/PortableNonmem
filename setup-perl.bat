:: Copyright (c) 2015, Mango Business Solutions Ltd
:: The script sets up environment for bundled Perl execution
:: Credits
:: The script is based on setup scripts from PKPDStick_72 developed by (c) Andrew C. Hooker 2014

@echo off

set home=%~dp0

rem  Environment variables
set TERM=
rem  Avoid collisions with other perl stuff on your system
set PERL_JSON_BACKEND=
set PERL_YAML_BACKEND=
set PERL5LIB=
set PERL5OPT=
set PERL_MM_OPT=
set PERL_MB_OPT=

rem  Don't need to modify the path if our Perl is already on the path
echo "%PATH%" | find "%home%\perl\bin;" >NUL
IF %ERRORLEVEL% NEQ 0 CALL :setpaths

rem  Reset the exit status
set ERRORLEVEL=0

GOTO :end

:setpaths

	rem  This redirects existing path entries so as not to conflict with those of the SEE bundled version of Perl
	set PATH=%PATH:perl\site\bin=perl\site\bin-foo%
	set PATH=%PATH:perl\bin=perl\bin-foo%
	set PATH=%PATH:perl\dll=perl\dll-foo%
	
	set PATH=%home%\perl\site\bin;%home%\perl\bin;%home%\perl\dll;%PATH%

:end
