:: Copyright (c) 2015, Mango Business Solutions Ltd
:: The script performs a test execution of NONMEM control file
@echo on

set home=%~dp0

CALL %home%\config.bat

CALL %home%\setup-NONMEM.bat %NM_INSTALL_DIR_NAME%

mkdir TEST

COPY %NM_INSTALL_DIR_NAME%\run\CONTROL5 TEST\
COPY %NM_INSTALL_DIR_NAME%\run\THEOPP TEST\

CD TEST

CALL nmfe73 CONTROL5 REPORT5.txt

CD ..

echo "Done. Now verify the outputs."