#!perl.exe
use FindBin qw($Bin);
use lib "$Bin/../site/lib/PsN_4_3_1";
# the above was entered by psnGlobalToLocalPaths

use PsN;
use model;
use tool::xv;
use strict;
use ui;
use Getopt::Long;
use common_options;

my $cmd_line = $0 . " " . join( " ", @ARGV );

## Configure the command line parsing
Getopt::Long::config("auto_abbrev");

## Declare the options
my %options;

my %required_options = ( "groups:i"=>'' );
my %optional_options = ( );

my $res = GetOptions( \%options, 
		      @common_options::get_opt_strings,
		      keys(%required_options),
		      keys(%optional_options) );

exit unless $res;
common_options::setup( \%options, 'crossval' ); #calls set_globals etc, initiates random sequence

## Check that we do have a model file
if ( scalar(@ARGV) < 1 ) {
  print "A model file must be specified.\n";
  exit;
}

if( scalar(@ARGV) > 1 ){
  print "crossval can only handle one modelfile, you listed: ",join(',',@ARGV),"\n";die;
  exit;
}

unless ( defined $options{'groups'} ){
  print "groups must be given\n" ;
  exit;
}

my $eval_string = common_options::model_parameters(\%options);

my $model = model -> new ( eval( $eval_string ),
			   filename                    => @ARGV[0],
			   ignore_missing_output_files => 1 );

my $xv =  tool::xv_step -> new( eval( $common_options::parameters ),
				nr_validation_groups => $options{'groups'},
				top_tool => 1,
				models => [$model],
				subtool_arguments => { modelfit => { eval( $common_options::parameters ),
								     directory => undef} },
				post_analyze => \&harvest_ofv,
    );

$xv -> run;


sub harvest_ofv{
  my $xv_object = shift;
  
  open XV_REPORT, '>', "xv_result.txt";
  print XV_REPORT "Prediction model OFV's\tEstimation model OFV's\n";
  for( my $i = 0; $i <= $#{$xv_object -> prediction_models}; $i++ ){
    print XV_REPORT $xv_object -> prediction_models -> [$i] -> outputs -> [0] -> ofv  -> [0][0], "\t";
    print XV_REPORT $xv_object -> estimation_models -> [$i] -> outputs -> [0] -> ofv  -> [0][0], "\n";
  }

  close XV_REPORT;
}
