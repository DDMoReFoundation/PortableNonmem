# Copyright (c) 2015, Mango Business Solutions Ltd
# The script updates paths used in NONMEM batch files
# Credits
# The script is based on setup scripts from PKPDStick_72 developed by (c) Andrew C. Hooker 2014
#

if($#ARGV<1) {
	print "Invalid number of arguments\n";
	print "Usage setup-NONMEM.pl <HOME_DIR> <NONMEM_DIR_NAME>";
	exit 10;
}

# Grab the parameters passed in
my $home = $ARGV[0];
my $nm_folder = $ARGV[1];

print "Preparing Nonmem batch scripts";
my $nmfe="nmfe73.bat";
my $nmfe_orig="nmfe73.bat.orig";
my $nmhelp="nmhelp.bat";
my $nmhelp_orig="nmhelp.bat.orig";

print "Preparing $nmfe...\n";
if ( -e "$home/$nm_folder/run/$nmfe_orig" ) {
    open( NMFE, "$home\\$nm_folder\\run\\$nmfe_orig" );
    open( NEW_NMFE, ">$home\\$nm_folder\\run\\$nmfe" );
    while( <NMFE> ){
		if( /dir=/ ){
			s/set dir=.*\S.*/set dir=$home\\$nm_folder/;
		}
		print NEW_NMFE;
    }
    close NEW_NMFE;
    close NMFE;
} else {
    print "Error: $nmfe_orig not found.\n";
    exit 100;
}

print "Preparing $nmhelp...\n";
if ( -e "$home/$nm_folder/$nmhelp_orig" ) {
    open( NMHELP, "$home\\$nm_folder\\$nmhelp_orig" );
    open( NEW_NMHELP, ">$home\\$nm_folder\\$nmhelp" );
    while( <NMHELP> ){
		if( /\[HELP_DIR\]/ ){
			s/\[HELP_DIR\]/$home\\$nm_folder\\help/;
		}
		if( /\[NM_HELP_APP\]/ ){
			s/\[NM_HELP_APP\]/$home\\$nm_folder\\help\\nmhelp.exe/;
		}
		print NEW_NMHELP;
    }
    close NEW_NMHELP;
    close NMHELP;
} else {
    print "Error: $nmhelp not found.\n";
    exit 100;
}

print "SUCCESS: NONMEM batch scripts have been updated";