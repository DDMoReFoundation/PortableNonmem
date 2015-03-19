#!perl.exe
use FindBin qw($Bin);
use lib "$Bin/../site/lib/PsN_4_3_1";
# the above was entered by psnGlobalToLocalPaths

use PsN;
use model;
use tool::frem;
use strict;
use Getopt::Long;
use common_options;
use Cwd;
use OSspecific;
use ui;

my $cmd_line = $0 . " " . join( " ", @ARGV );

## Configure the command line parsing
Getopt::Long::config("auto_abbrev");

my %options;
## Declare the options

my %required_options = ();
my %optional_options = ( 'invariant:s' => undef,
						 'time_varying:s' => undef,
						 'occasion:s' => undef,
						 'parameters:s' => undef,
						 'dv:s' => undef,
						 'vpc!' => undef,
						 'check!' => undef,
						 'estimate:i' => undef,
						 'start_eta:i' => undef);

my $res = GetOptions( \%options,
		      @common_options::get_opt_strings,
		      keys(%required_options),
		      keys(%optional_options) );
exit unless $res;

common_options::setup( \%options, 'gls' ); #get defaults, 
#calls set_globals etc, initiates random sequence

my %help_text;

$help_text{Pre_help_message} = <<'EOF';
  <h3 class="heading1">gls</h3>

    Generalised Least Squares approximation of residual error.

EOF

$help_text{Options} = <<'EOF';      
    Options:

      The options are given here in their long form. Any option may be
      abbreviated to any nonconflicting prefix. The -threads option
      may be abbreviated to -thr.

      The following options are valid:
EOF

$help_text{-h} = <<'EOF';
      -h | -?
      
      With -h or -? gls will print a list of options and exit.
EOF
      
$help_text{-help} = <<'EOF';      
      -help
      
      With -help frem will print this, longer, help message.
EOF

$help_text{-invariant} = <<'EOF';
      -invariant=list

EOF
$help_text{-time_varying} = <<'EOF';
      -time_varying=list

EOF

$help_text{-occasion} = <<'EOF';
      -occasion=column


EOF

$help_text{-parameters} = <<'EOF';
      -parameters=list

EOF

$help_text{-dv} = <<'EOF';
      -dv=column

      Default DV
EOF
$help_text{-start_eta} = <<'EOF';
      -start_eta=x

      Default 1
EOF

$help_text{-vpc} = <<'EOF';
      -vpc

      Default not set.
EOF

$help_text{-check} = <<'EOF';
      -check

      Default not set.
EOF

$help_text{-estimate} = <<'EOF';
      -estimate=N

EOF


$help_text{Post_help_message} = <<'EOF';
    Also see 'psn_options -h' for a description of common PsN options.
EOF

common_options::online_help( 'frem', \%options, \%help_text, \%required_options, \%optional_options);

## Check that we do have a model file
if ( scalar(@ARGV) < 1 ) {
  print "An input model file must be specified. Use 'frem -h' for help.\n";
  exit;
}

if( scalar(@ARGV) > 1 ){
  print "FREM can only handle one modelfile, you listed: ",join(',',@ARGV),". Use 'frem -h' for help.\n";die;
  exit;
}

my $done_file = 'template_models_done.pl';
if (defined $options{'directory'} and -d $options{'directory'}){
	if(-e $options{'directory'}.'/'.$done_file){
		#use done file parameters, ignore command-line
		foreach my $opt ('invariant','time_varying','parameters','start_eta','occasion','dv'){
			if (defined $options{$opt}){
				print "The file $done_file already exists in directory ".$options{'directory'}.", option -$opt not allowed.";
				exit;
			}
		}
	}else{
		print "Cannot restart in existing directory ".$options{'directory'}." because file $done_file is not found there.";
		exit;
	}
}else{
	#input checks
    unless (defined $options{'invariant'} or defined $options{'time_varying'}){
		print "At least one of options invariant or time_varying must be given when starting a new run.\n";
		exit;
    }
    if ((defined $options{'time_varying'}) xor ( defined $options{'parameters'})){
		print "Options time_varying and parameters must either be both given or both not given\n";
		exit;
    }
	
}


#parse input
my @invariant=();
if (defined $options{'invariant'}){
    #comma-separated list of names
    foreach my $name (split(/,/,$options{'invariant'})){
		if (length($name)>0){
			push(@invariant,$name);
		}
    }
}

my @time_varying=();
if (defined $options{'time_varying'}){
    #comma-separated list of names
    foreach my $name (split(/,/,$options{'time_varying'})){
		if (length($name)>0){
			push(@time_varying,$name);
		}
    }
}

my @parameters=();
if (defined $options{'parameters'}){
    #comma-separated list of names
    foreach my $name (split(/,/,$options{'parameters'})){
		if (length($name)>0){
			push(@parameters,$name);
		}
    }
}

my $eval_string = common_options::model_parameters(\%options);

my $model = model -> new ( eval( $eval_string ),
			   filename                    => $ARGV[0],
			   ignore_missing_output_files => 1);
if ($model->tbs){
	die "frem is incompatible with option -tbs\n";
}

if( defined $model -> msfi_names() ){
    my @needed_files;
    foreach my $msfi_files( @{$model -> msfi_names()} ){
		#loop $PROB
		if (defined $msfi_files){
			foreach my $msfi_file( @{$msfi_files} ){
				#loop instances
				if ( defined $msfi_file ){
					my ( $dir, $file ) = OSspecific::absolute_path(cwd(),$msfi_file);
					push (@needed_files,$dir.$file) ;
				}
			}
		}
    }
    if (scalar(@needed_files)>0){
		if( defined $model -> extra_files ){
			push(@{$model -> extra_files},@needed_files);
		}else{
			$model -> extra_files(\@needed_files);
		}
    }
    
}


if ( scalar (@{$model-> problems}) > 1 ){
    print "Cannot have more than one \$PROB in the input model.\n";
    exit;
}

my $est_record = $model -> record( problem_number => 1,
				   record_name => 'estimation' );
unless( scalar(@{$est_record}) > 0 ){
  print "The input model must have a \$EST record\n";
  exit;
}

my $frem = tool::frem -> 
    new ( eval( $common_options::parameters ),
		  models	     => [ $model ],
		  top_tool           => 1,
		  done_file => $done_file,
		  parameters => \@parameters,
		  time_varying => \@time_varying,
		  invariant => \@invariant,
		  start_eta => $options{'start_eta'}, 
		  estimate => $options{'estimate'}, 
		  check => $options{'check'}, 
		  vpc => $options{'vpc'}, 
		  occasion => $options{'occasion'}, 
		  dv => $options{'dv'}); 

#ui -> print( category => 'frem',
#	     message => "have new frem\n" );


$frem-> print_options (cmd_line => $cmd_line,
		      toolname => 'frem',
		      local_options => [keys %optional_options],
		      common_options => \@common_options::tool_options);

   
$frem -> run;

if ($frem->vpc and -e $frem->directory.'frem_vpc.mod'){
	print "The prepared frem vpc model is ".$frem->directory."frem_vpc.mod\n";
}

#$frem -> prepare_results;
#$frem -> print_results; #only for frem_results.csv
ui -> print( category => 'frem',
	     message => "frem done\n" );

