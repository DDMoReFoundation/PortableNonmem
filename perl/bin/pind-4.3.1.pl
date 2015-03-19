#!perl.exe
use FindBin qw($Bin);
use lib "$Bin/../site/lib/PsN_4_3_1";
# the above was entered by psnGlobalToLocalPaths

use PsN;
use model;
use tool::pind;
use strict;
use Getopt::Long;
use common_options;
use Cwd;

my $cmd_line = $0 . " " . join( " ", @ARGV );

## Configure the command line parsing
Getopt::Long::config("auto_abbrev");

my %options;
## Declare the options

my %required_options;

my %optional_options = ("lst_file:s"=>'',
			"njd:s"=>'',
			"ignore_individuals_above:i"=>'',
			"ind_param:s"=>''
			);

my $res = GetOptions( \%options,
		      @common_options::get_opt_strings,
		      keys(%required_options),
		      keys(%optional_options) );
exit unless $res;

if (defined $options{'njd'}){
  my ( $fulldir, $njdfile ) = OSspecific::absolute_path( getcwd(), $options{'njd'});
  $options{'njd'} = $fulldir . $njdfile;
}


common_options::setup( \%options, 'pind' ); #calls set_globals etc, initiates random sequence

my %help_text;

$help_text{Pre_help_message} = <<'EOF';
  pind

    Individual probabilities.

  Usage:
EOF

$help_text{Options} = <<'EOF';      
    Options:

      The options are given here in their long form. Any option may be
      abbreviated to any nonconflicting prefix. The -threads option
      may be abbreviated to -t(or even -thr).

      The following options are valid:
EOF

$help_text{-h} = <<'EOF';
      -h | -?
      
      With -h or -? pind will print a list of options and exit.
EOF
      
$help_text{-help} = <<'EOF';      
      -help
      
      With -help pind will print this, longer, help message.
EOF

$help_text{-lst_file} = <<'EOF';
      -lst_file='filename'

      Optional, the lst-file from where to read initial parameter estimates. 
      Default is the same name as the model file but with .mod replaced with .lst.
EOF

$help_text{-njd} = <<'EOF';
      -njd='filename'

      Experimental. Optional, by default not used. Filename for 
      new joint density column.
EOF

$help_text{-ignore_individuals_above} = <<'EOF';
      -ignore_individuals_above='integer'

      Experimental. Only allowed together with -njd, in that case
      default value is 100. Option adds line 
      IGNORE=(ID.GT.X) to DATA record, where X is option value.
      If the IGNORE statement should not be changed even though 
      option -njd is used, set -ignore_individuals_above=0.
EOF

$help_text{-ind_param} = <<'EOF';
      -ind_param=eta|theta

      Optional, default eta. The parameter to set in individual ofv model files.
      Possibilities are eta or theta.
EOF


$help_text{Post_help_message} = <<'EOF';
      Also see 'psn_options -h' for a description of common options.
EOF

common_options::online_help( 'pind', \%options, \%help_text, \%required_options, \%optional_options);

## Check that we do have a model file
if ( scalar(@ARGV) < 1 ) {
  print "A simulation model file must be specified. Use 'pind -h' for help.\n";
  exit;
}

if( scalar(@ARGV) > 1 ){
  print "PIND can only handle one modelfile, you listed: ",join(',',@ARGV),". Use 'pind -h' for help.\n";
  exit;
}

my $lst_file;
if (defined $options{'lst_file'}){
  $lst_file=$options{'lst_file'};
} else {
  #assume modelfile ends with .mod
  $lst_file = (substr ($ARGV[0],0,-3)).'lst'; #keep from beginning, skip last four characters
  unless ( -e $lst_file ){
    print "When option -lst_file is omitted, the name of the lst-file is assumed to be the same\n".
	"as the modelfile except that the last three letters are lst. Cannot find file $lst_file.\n";
    exit;
  }
}
my ($dir,$file)=OSspecific::absolute_path(cwd(),$lst_file);
$lst_file = $dir . $file;


unless ( defined $options{'clean'} ){
  # Clean may be changed by default 
  $options{'clean'} = 1;
}

my $eval_string = common_options::model_parameters(\%options);

my $model = model -> new ( eval( $eval_string ),
			   extra_output                => ['fort.80'],
			   filename                    => $ARGV[0],
			   ignore_missing_output_files => 1 );

my $pind = tool::pind -> 
    new ( eval( $common_options::parameters ),
	  models	     => [$model],
	  lst_file           => $lst_file,
	  njd           => $options{'njd'},
	  ignore_individuals_above => $options{'ignore_individuals_above'},
	  ind_param           => $options{'ind_param'}
	  );

$pind->print_options (cmd_line => $cmd_line,
		       toolname => 'pind',
		       local_options => [keys %optional_options],
		       common_options => \@common_options::tool_options);

$pind->run;

open( TMP, ">", 'ofv.done' );
print TMP "1"; 
close( TMP );

ui -> print( category => 'pind',
	     message => "pind done" );
