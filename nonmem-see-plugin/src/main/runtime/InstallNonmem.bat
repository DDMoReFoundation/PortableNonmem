:: Copyright (c) 2015, Mango Business Solutions Ltd
:: 
:: A Tool for installing portable NONMEM into SEE instance.
::
@ECHO OFF

echo Installing NONMEM...

SET HOME=%~dp0
SET HOME=%HOME:~0,-1%

SET ZIP_FILE=%HOME%\nm_7.3.0_g.zip
SET TARGET_DIR=%HOME%
SET NM_FOLDER=%TARGET_DIR%\nm_7.3.0_g

IF NOT EXIST %ZIP_FILE% (
	echo %ZIP_FILE% does not exist!
	GOTO failed
)
IF EXIST %NM_FOLDER% (
	echo %NM_FOLDER% already exists. Have you already installed NONMEM in this SEE instance?
	GOTO failed
)

echo Extracting %ZIP_FILE%...
powershell -Command "$shell = new-object -com shell.application; $zip = $shell.NameSpace('%ZIP_FILE%'); foreach($item in $zip.items()) { $shell.Namespace('%TARGET_DIR%').copyhere($item, 1044); }"
GOTO success


:failed
echo NONMEM installation failed.
pause
exit \B 1

:success
echo NONMEM installed successfully.
pause
exit \B 0