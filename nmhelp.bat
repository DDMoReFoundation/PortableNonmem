:: Copyright (c) 2015, Mango Business Solutions Ltd
:: The script updates paths used in NONMEM batch files
:: Credits
:: The script is based on setup scripts from PKPDStick_72 developed by (c) Andrew C. Hooker 2014

echo "Starting up NONMEM help system"
@echo off
set OLD_CWD=%cd%

cd [HELP_DIR]
echo on
[NM_HELP_APP] %*

@echo off
cd %OLD_CWD%
echo on
