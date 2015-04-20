Portable NONMEM for SEE
=============================================
This is a portable NONMEM packaging project that produces SEE platform bundle.

Provider:  [ Mango Solutions ](http://www.mango-solutions.com "data analysis that delivers")

Some scripts are based on PKPDStick_72 developed by (c) Andrew C. Hooker 2014

Glossary
---------------------------------------------
NM_INSTALLER_HOME - directory holding this README.txt file


Contents
---------------------------------------------
There are the following files in the project:

* config.bat - configuration file for the *installer*. Not used by resulting distribution.
* setup-NONMEM.bat - environment setup script, used by clients and test script
* setup-NONMEM.pl - script updating NONMEM execution scripts, used by clients and test script
* setup-perl.bat - environment setup script for perl
* setup-fortran-compiler.bat - environment setup script for fortran compiler
* test.bat - tests NONMEM installation
* nmhelp.bat - a script that starts up NONMEM help system from command line
* install.bat - executes NONMEM installer
* post-install.bat - a script that post-processes NONMEM installation and prepares it for SEE packaging
* gfortran - gfortran installation
* perl - perl installation
* nonmem-see-plugin - Maven module producing SEE Plugin



Guide
---------------------------------------------
To create portable NONMEM installation:

* Obtain NONMEM CD Archive (e.g. from ICT or from official FTP)
* Unzip NONMEM CD Archive into NM_INSTALLER_HOME
* Obtain valid NONMEM license and copy it into NM_INSTALLER_HOME (this license will just be used for installation process, the resulting binary won't include it)
* Update NM_INSTALLER_HOME\config.bat as per version of NONMEM that you are installing
* Update NM_INSTALLER_HOME\setup-NONMEM.bat as per version of  (e.g. set NONMEM installation directory name)
* Open command prompt (Start Menu->'cmd.exe' [enter])
* Go into the NM_INSTALLER_HOME

	CD NM_INSTALLER_HOME

* invoke install.bat
* Provide feedback when prompted by NONMEM installation script. (use defaults (<enter>) if not sure)
* Invoke post-install.bat
* Move the NM_INSTALLER_HOME under different path, e.g.:

	MOVE NM_INSTALLER_HOME some\other\dir

* Go to the new location of the installer dir
* Run test.bat
* Verify the results


SEE Bundle Packaging
---------------------------------------------
* Build portable nonmem installation (see above)
* Create a zip archive of the produced nonmem installation directory (e.g. 'nm_7.3.0_g')
* Go to nonmem-see-plugin
* Run 'mvn clean verify' 
	Note: at the time of writting the build by defaul will look for '<NM_INSTALLER_HOME>/nm_7.3.0_g.zip', you can change the file name by passing '-Dstandalone.nonmem.installation.archive.name=<archive_file_name.zip>' to Maven command
* the resulting nonmem-see-plugin bundle will be in '<NM_INSTALLER_HOME>/nonmem-see-plugin/target'


SEE Bundle Verification
---------------------------------------------
* unzip nonmem-see-plugin*.zip from 'target' directory (see section above)
* Copy '<NM_INSTALLER_HOME>/test.bat' to where you unzipped NONMEM SEE bundle
* Copy nonmem.license to Nonmem installation in SEE bundle directory
* go to SEE bundle directory and run test.bat
* verify that the execution was successful.


