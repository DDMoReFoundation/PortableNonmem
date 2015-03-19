#!perl.exe
use FindBin qw($Bin);
use lib "$Bin/../site/lib/PsN_4_3_1";
# the above was entered by psnGlobalToLocalPaths

use PsN;
use model;
use tool::gls;
use strict;
use Getopt::Long;
use common_options;
use Cwd;
use OSspecific;

my $cmd_line = $0 . " " . join( " ", @ARGV );

## Configure the command line parsing
Getopt::Long::config("auto_abbrev");

my %options;
## Declare the options

my %required_options = ();
my %optional_options = ( 'samples:i' => undef,
			 'iwres_shrinkage:f' => undef,
			 'ind_shrinkage!' => undef,
			 'reminimize!' => undef,
			 'set_simest!' => undef,
			 'sim_table!' => undef,
			 'additive_theta:f' => undef,
			 'gls_model!' => undef);

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
      may be abbreviated to -thr

      The following options are valid:
EOF

$help_text{-h} = <<'EOF';
      -h | -?
      
      With -h or -? gls will print a list of options and exit.
EOF
      
$help_text{-help} = <<'EOF';      
      -help
      
      With -help gls will print this, longer, help message.
EOF

$help_text{-samples} = <<'EOF';
      -samples=N

      Default not used. Only relevant if -ind_shrinkage is set and -gls_model 
      is not set. Creates N copies of input model with different seeds in $SIM. 
      Run to get N IWRES values for each data point y_ij. Compute 
      iwres_shrinkage_ij =1-stdev(IWRES_ij(1:N))
EOF
$help_text{-set_simest} = <<'EOF';
      -set_simest

      Default not used. Only relevant if -gls_model is not set. 
      Change $SIM and $EST in simulation model (if used) and $EST in gls model 
      based on tags in the input model.
EOF

$help_text{-sim_table} = <<'EOF';
      -sim_table

      Default not set. Only relevant if -ind_shrinkage is set and -gls_model
      is not set. PsN will delete all existing $TABLE in the simulation models 
      before adding a $TABLE for per-observation IWRES values, but if option 
      -sim_table is set then an extra $TABLE with diagnostic output is added 
      to each simulation model.

EOF

$help_text{-additive_theta} = <<'EOF';
      -additive_theta=XX

      Default not used. In gls model, add a small and fix additive error in W. 
      The error is added by changing W=SQRT(<expression>) to 
      W=SQRT(THETA(T)**2+<expression>) in the gls model, where T is the order 
      number of new $THETA XX FIX added to the model.
EOF

$help_text{-reminimize} = <<'EOF';
      -reminimize

      Default not set. Only relevant if -ind_shrinkage is set and -gls_model is 
      not set. By default, simulated datasets will be run with MAXEVAL=0 
      (or equivalent for non-classical estimation methods). If option -reminimize 
      is set then $EST will be the same as in the input model.
EOF

$help_text{-iwres_shrinkage} = <<'EOF';
      -iwres_shrinkage=X

      Default not used. Forbidden in combination with -ind_shrinkage. If the 
      population iwres shrinkage from the input model run is already available, 
      or if a special values such as 0 or 1 is desired, the user can give the 
      value as input on the command-line. Important note: PsN reports shrinkage 
      in percent in the raw_results file, so if using the value from raw_results 
      as input that value must be divided by 100. 
EOF

$help_text{-ind_shrinkage} = <<'EOF';
      -ind_shrinkage

      Default not set. Compute per-observation iwres-shrinkage based on simulations. 
EOF

$help_text{-gls_model} = <<'EOF';
      -gls_model

      Default not set. Only possible together with option -iwres_shrinkage 
      or -ind-shrinkage. This option is to be used when a datafile with all data 
      needed for the gls model run is already available, i.e. all input for the 
      original model plus columns with PRED and IPRED from the original model run, 
      and if -ind_shrinkage is set also a ISHR column with 
      per observation shrinkage values. The option indicates that $DATA specifies 
      the file with the gls input data, and that $INPUT lists the parameters in the 
      datafile. In $INPUT the columns PPRE and PIPR must be present as headers for 
      PRED and IPRED values, plus ISHR as header for the shrinkage column if 
      -ind_shrinkage is set.
      Then PsN will add the GLSP code to the gls model and run it directly, saving 
      the original model run.

      Note that a run with the ebe_npde program will automatically generate
      a complete input file for gls (including PRED IPRED and per-observation shrinkage).
EOF

$help_text{Post_help_message} = <<'EOF';
    Also see 'psn_options -h' for a description of common PsN options.
EOF

common_options::online_help( 'gls', \%options, \%help_text, \%required_options, \%optional_options);

## Check that we do have a model file
if ( scalar(@ARGV) < 1 ) {
  print "An input model file must be specified. Use 'gls -h' for help.\n";
  exit;
}

if( scalar(@ARGV) > 1 ){
  print "GLS can only handle one modelfile, you listed: ",join(',',@ARGV),". Use 'gls -h' for help.\n";die;
  exit;
}

if (defined $options{'gls_model'} and not 
    (defined $options{'iwres_shrinkage'} or defined $options{'ind_shrinkage'})){
  print "When option gls_model is set option iwres_shrinkage or ind_shrinkage must also be given\n";
  exit;
}

if (defined $options{'iwres_shrinkage'} and (defined $options{'ind_shrinkage'})){
  print "Option iwres_shrinkage cannot be used together with option ind_shrinkage\n";
  exit;
}

if (defined $options{'reminimize'}){
  if (defined $options{'gls_model'}){
    print "Option reminimize cannot be used together with option gls_model\n";
    exit;
  }
  if (not defined $options{'ind_shrinkage'}){
    print "Option reminimize cannot be used without option ind_shrinkage\n";
    exit;
  }
}

if ((defined $options{'ind_shrinkage'}) and (not defined $options{'gls_model'})){
  if (not defined $options{'samples'}){
    print "Option samples is required when ind_shrinkage but not gls_model is set\n";
    exit;
  }
  if ($options{'samples'}<2){
    print "Option samples must be at least 2\n";
    exit;
  }
}

if ((defined $options{'gls_model'}) and (defined $options{'set_simest'})){
  print "Option set_simest must not be used in combination with gls_model.\n";
  exit;
}


my $eval_string = common_options::model_parameters(\%options);

my $model = model -> new ( eval( $eval_string ),
			   filename                    => $ARGV[0],
			   ignore_missing_output_files => 1);

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

my $tnpri=0;
if ( scalar (@{$model-> problems}) > 2 ){
  die('Cannot have more than two $PROB in the input model.');
}elsif  (scalar (@{$model-> problems}) == 2 ){
  if ((defined $model-> problems->[0]->priors()) and 
      scalar(@{$model-> problems->[0] -> priors()})>0 ){
    foreach my $rec (@{$model-> problems->[0] -> priors()}){
      foreach my $option ( @{$rec -> options} ) {
	if ((defined $option) and 
	    (($option->name eq 'TNPRI') || (index('TNPRI',$option ->name ) == 0))){
	  $tnpri=1;
	}
      }
    }
  }
  if ($tnpri){
    unless( defined $model-> extra_files ){
      die('When using $PRIOR TNPRI you must set option -extra_files to '.
		     'the msf-file, otherwise the msf-file will not be copied to the NONMEM '.
		     'run directory.');
    }

  }else{
    print 'The input model must contain exactly one problem, unless'.
	' first $PROB has $PRIOR TNPRI'."\n";
    exit;
  }
}




my $est_record = $model -> record( problem_number => (1+$tnpri),
				   record_name => 'estimation' );
unless( scalar(@{$est_record}) > 0 ){
  print "The input model must have a \$EST record\n";
  exit;
}

my $gls = tool::gls -> 
    new ( eval( $common_options::parameters ),
	  iwres_shrinkage => $options{'iwres_shrinkage'},
	  ind_shrinkage => $options{'ind_shrinkage'},
	  reminimize => $options{'reminimize'},
	  additive_theta => $options{'additive_theta'},
	  gls_model => $options{'gls_model'},
	  sim_table => $options{'sim_table'},
	  set_simest => $options{'set_simest'},
	  models	     => [ $model ],
	  samples            => $options{'samples'} );


$gls-> print_options (cmd_line => $cmd_line,
		      toolname => 'GLS',
		      local_options => [keys %optional_options],
		      common_options => \@common_options::tool_options);

   
$gls -> run;
ui -> print( category => 'gls',
	     message => "gls done\n" );
