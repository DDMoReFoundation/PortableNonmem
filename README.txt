Portable NONMEM for SEE
=============================================
This is a portable NONMEM packaging project that produces SEE platform bundle.

Provider:  [ Mango Solutions ](http://www.mango-solutions.com "data analysis that delivers")

Some scripts are based on PKPDStick_72 developed by (c) Andrew C. Hooker 2014

Glossary
---------------------------------------------
NM_INSTALLER_HOME - directory holding this README.txt file


Guide
---------------------------------------------
To create portable NONMEM installation:
* Obtain NONMEM CD Archive (e.g. from ICT or from official FTP)
* Unzip NONMEM CD Archive into NM_INSTALLER_HOME
* Copy nonmem license into NM_INSTALLER_HOME.
* Update NM_INSTALLER_HOME\config.bat as per version of NONMEM that you are installing
* Open command prompt (Start Menu->'cmd.exe' [enter])
* Go into the NM_INSTALLER_HOME

	CD NM_INSTALLER_HOME

* invoke install.bat
* Provide feedback when prompted by NONMEM installation script. 
* Invoke post-install.bat
* Move the NM_INSTALLER_HOME under different path, e.g.:

	MOVE NM_INSTALLER_HOME some\other\dir

* Go to the new location of the installer dir
* Run test.bat
* Verify the results


SEE Bundle Packaging
---------------------------------------------
* Run create-SEE-bundle.bat
* The SEE bundle name will be NONMEM_SEE directory


SEE Bundle Verification
---------------------------------------------
* Copy test.bat to the SEE bundle directory
* Copy nonmem.license to Nonmem installation in SEE bundle directory
* go to SEE bundle directory and run test.bat
* verify that the execution was successful.
* remove nonmem.lic file from SEE bundle NONMEM license directory 
* remove TEST directory and test.bat file from SEE bundle directory


