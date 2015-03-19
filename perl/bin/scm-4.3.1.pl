#!perl.exe
use FindBin qw($Bin);
use lib "$Bin/../site/lib/PsN_4_3_1";
# the above was entered by psnGlobalToLocalPaths

use PsN;
use file;
use model;
use tool::scm;
use tool::scm::config_file;
use tool::modelfit;
use strict;
use Getopt::Long;
use Cwd;
use common_options;
use ui;
use OSspecific;
use File::Copy qw/cp mv/;

my $cmd_line = $0 . " " . join( " ", @ARGV );

my %options;

my %required_options = ( "config_file:s" => '');

my %optional_options = ( "search_direction:s" => 'forward|backward|both',
						 "gof:s" => '',
						 "global_init:s" => '',
						 "logfile:s" => '',
						 "model:s" => '',
						 "noabort!" => '',
						 "max_steps:i" => '',
						 "p_value:s" => '',
						 "p_forward:s" => '',
						 "p_backward:s" => '',
						 "do_not_drop:s" => '',
						 "linearize!" => '',
						 "epsilon!" => '',
						 "foce!" => '',
						 "lst_file:s" => '',
						 "update_derivatives!" => '',
						 "only_successful!" => '',
						 "parallel_states!" => '',
						 "error:s"=> '');

my $res = GetOptions( \%options, 
					  @common_options::get_opt_strings,
					  keys(%required_options),
					  keys(%optional_options)
	);
exit unless $res;

#cannot run setup here, must read config file first

my %help_text;
$help_text{Pre_help_message} = <<'EOF';
<h3 class="heading1">scm</h3>

	Stepwise covariate model building from NONMEM models.

	<h3 class="heading1">Usage:</h3>
EOF

    $help_text{Description} = <<'EOF';
	<h3 class="heading1">Description:</h3>

    The Stepwise Covariate Model (SCM) building tool of PsN implements
    Forward Selection and Backward Elimination of covariates to a
    model. In short, one model for each relevant parameter-covariate
    relationship is prepared and tested in a univariate manner. In the
    first step the model that gives the best fit of the data according
    to some criteria is retained and taken forward to the next
    step. In the following steps all remaining parameter-covariate
    combinations are tested until no more covariates meet the criteria
    for being included into the model. The Forward Selection can be
    followed by Backward Elimination, which proceeds as the Forward
    Selection but reversely, using stricter criteria for model
    improvement.

    <br><br> 

    The Stepwise Covariate Model building procedure is run by the PsN
    tool <span class="style5">scm</span>. The options to <span
    class="style5">scm</span> can (and should) be rather complex to
    describe all features of a covariate model building procedure.
    A configuration file should be written for each scm run. 
EOF

    $help_text{Examples} = <<'EOF';
<h3 class="heading1">Examples:</h3>

    Execute an SCM using parameters set in the config file
    'phenobarbital.scm'.
    
	<p class="style2">$ scm -config_file=phenobarbital.scm</p>

    Execute an SCM using parameters set in the config file
    'phenobarbital.scm'. But override the retries and the seed
    parameter.

	<p class="style2">$ scm -config_file=phenobarbital.scm -retries=5 -seed=12345 phenobarbital.mod</p>
EOF
	
    $help_text{Options} = <<'EOF';
<h3 class="heading1">Options:</h3>

    The options are given here in their long form. Any option may be
    abbreviated to any nonconflicting prefix. The -threads option may
    be abbreviated to <span class="style2">-thr</span>.

    The following options are valid:
EOF

    $help_text{-h} = <<'EOF';
<p class="style2">-h | -?</p>

    With -h or -? scm will print a list of options and exit.
EOF

    $help_text{-help} = <<'EOF';
<p class="style2">-help</p>

    With -help scm will print this, longer, help message.
EOF

    $help_text{-config_file} = <<'EOF';
<p class="style2">-config_file</p>

    A file of an scm configuration file.
EOF

    $help_text{-search_direction} = <<'EOF';
<p class="style2">-search_direction</p>

    Which search task to perform: backward, forward or both is allowed.
EOF
	$help_text{-max_steps} = <<'EOF';
-max_steps=N

    Do not take more that max_steps forward steps,
    even if there are more covariates left to add and a significant
    inclusion was made in the last step.
EOF

    $help_text{-gof} = << 'EOF';
<p class="style2">-gof</p>

    Goodness of fit function. Either pval (default) or ofv.
EOF
    
    $help_text{-global_init} = << 'EOF';
<p class="style2">-global_init</p>
    Default is 0.001. With global_init option the initial estimates of parameters
    in covariate parameterizations are set to global_init. If using inits section 
    in configuration file individual initial values are used instead of one global.
EOF

    $help_text{-logfile} = << 'EOF';
<p class="style2">-logfile</p>

    Default scmlog.txt. The name of the logfile.
EOF

    $help_text{-model} = << 'EOF';
<p class="style2">-model</p>

    The name of the basic model file, without any parameter-covariate
    relations included.
EOF

    $help_text{-p_value} = << 'EOF';
<p class="style2">-p_value</p>

    Use this option to set the p_value for both forward and backward
    steps simultaneously.
EOF

    $help_text{-p_forward} = << 'EOF';
<p class="style2">-p_forward</p>

    Using the p_forward option, you can specify the p-value to use for
    the forward selection.
EOF

    $help_text{-p_backward} = << 'EOF';
<p class="style2">-p_backward</p>

    Using the p_backward option, you can specify the p-value to use
    for the backward deletion.
EOF
    
    $help_text{-do_not_drop} = << 'EOF';
<p class="style2">-do_not_drop</p>

    To save memory it is desirable to minimize the number of undropped columns
    in the candidate models. The scm program uses the '=DROP' syntax of NONMEM 
    to exclude the covariate columns that are not currently tested in a 
    specific candidate model. If some covariates are used in the PK or PRED 
    code in the basic model or in an IGNORE/ACCEPT statement you must list them 
    using the do_not_drop option to prevent them from being dropped in candidate
    models where they are not tested for inclusion. 
    If the -linearize option is used, do_not_drop has a different usage. There
    you must set do_not_drop for all $INPUT items except ID DV and MDV that 
    are used in an IGNORE/ACCEPT statement, and , if option -error_code is used,
    parameters except IPRED and EPS that are used in error_code. Do *not* 
    list parameters used in PK or PRED if -linearize is used.
EOF

    $help_text{-noabort} = <<'EOF';
<p class="style2">-noabort</p>

    Default not set. Only relevant with the linearize method. If set,
    the program will add NOABORT to $EST of the linearized models.
    
EOF
    $help_text{-linearize} = <<'EOF';
<p class="style2">-linearize</p>

    Add covariate relations to a linearized version of the input model instead of
    to the original nonlinear model.
EOF
    $help_text{-second_order} = <<'EOF';
<p class="style2">-second_order</p>

    Only relevant with linearize method. Use second order Taylor expansion around
    ETAs instead of default first order expansion.
    The user must ensure that CONDITIONAL LAPLACIAN is set in $EST.
    
EOF
    $help_text{-foce} = <<'EOF';
<p class="style2">-foce</p>

    Set by default. Only relevant with linearize method. Expand around 
    conditional ETA estimates instead of around ETA=0.    
EOF
    $help_text{-update_derivatives} = <<'EOF';
<p class="style2">-update_derivatives</p>

    Only relevant with linearize method. Run nonlinear model with new covariate 
    added to get updated derivates after each iteration, instead of reusing 
    derivatives from model without covariates.
EOF
    $help_text{-derivatives_data} = <<'EOF';
<p class="style2">-derivatives_data</p>

    Only relevant with linearize method. Give derivatives data as table input
    rather than letting the scm run the nonlinear model to obtain them. Saves time.
EOF
    $help_text{-error} = <<'EOF';
<p class="style2">-error</p>

    Only relevant with linearize method, and only if -no-epsilon is set. 
    Use an approximated linearization of the error model instead of an exact.

    Alternatives are add (for additive), prop (for proportional),
    propadd (for proportional plus additive) or user (for user defined).
    The error model must be defined in a particular way when this option is used,
    see the scm userguide for details.
EOF
    $help_text{-epsilon} = <<'EOF';
<p class="style2">-epsilon</p>

    Only relevant with linearize method. Linearize with respect to epsilons,
    set by default. Disable with -no-epsilon.
EOF
    $help_text{-lst_file} = <<'EOF';
<p class="style2">-lst_file</p>

    Default not used. Update original model with final estimates from this file 
    before running model to obtain derivatives.
EOF
    $help_text{-only_successful} = <<'EOF';
<p class="style2">-only_successful</p>

    Only consider runs with MINIMIZATION SUCCESSFUL 
    (or equivalent for non-classical estimation methods) when 
    selecting the covariate to add/remove in each step.
EOF
    $help_text{-parallel_states} = <<'EOF';
<p class="style2">-parallel_states</p>

    If this option is set, scm will test all valid_states simultaneously
    instead of the default method to test valid_states sequentially, only
    testing a higher state if the preceeding state has been included in the model.
EOF

    $help_text{Post_help_message} = <<'EOF';
Also see 'psn_options -h' for a description of common options.
EOF

	common_options::online_help( 'scm', \%options, \%help_text, \%required_options, \%optional_options);

if ( $options{'config_file'} eq '' and (scalar(@ARGV)==1)){
    $options{'config_file'} = $ARGV[0];
}else{
    $options{'model'} =  $ARGV[0];
}
if ( $options{'config_file'} eq ''){
    print "Please specify a config file \n";
    exit;
}

my $config_file;
if( -e $options{'config_file'} ){
	my $file = file -> new( name => $options{'config_file'}, path => '.' );
	$config_file = 'tool::scm::config_file' -> new ( file => $file );


	foreach my $option ( keys %{$config_file -> valid_scalar_options} ){
		if( defined $options{$option} ) {
			$config_file -> $option($options{$option});
		}elsif (defined $config_file -> $option){
			#store tool_options so that can use common_options::restore in scm
			foreach my $opt (@common_options::tool_options){
				$opt =~ s/[!:|].*//g; #get rid of :s |? :i etcetera
				if ($opt eq $option){
					$options{$option} = $config_file -> $option;
					last;
				}
			}
		}
	}

	foreach my $option ( keys %{$config_file -> valid_code_options} ){
		if( $options{$option} ){
			$config_file -> $option(eval($options{$option}));
		}
	}

	foreach my $option ( keys %{$config_file -> valid_array_options} ){
		if( $options{$option} ){
			my @arr = split( /,/ , $options{$option});
			$config_file -> $option(\@arr);
		}
	}

} else {
	print "Error: config file $options{'config_file'} is missing.\n" ;
	exit;
}

#calls get_defaults, set_globals etc, initiates random sequence, store tool_options
common_options::setup( \%options, 'scm' ); 

if ($config_file->linearize){
	die "Option -second_order is currently broken" 
		if $config_file->second_order();
	#two new options, linearize and lst-file

	if ($config_file->second_order()){
		print "Warning: Option -second_order is intended for use together with option -foce\n" 
			unless $config_file->foce();
	}

	die "option -linearize only works with NONMEM7" unless ($PsN::nm_major_version == 7);


	if ($config_file->derivatives_data()){
		my ( $dir, $file ) = OSspecific::absolute_path('',$config_file->derivatives_data());
		$config_file->derivatives_data($dir . $file);
	}
	if ($config_file->lst_file()){
		my ( $dir, $file ) = OSspecific::absolute_path('',$config_file->lst_file());
		$config_file->lst_file($dir . $file);
	}

}else{
	die "Option -foce is only allowed together with option -linearize" 
		if $config_file->foce();
	die "Option -second_order is only allowed together with option -linearize" 
		if $config_file->second_order();
	die "Option -lst_file is only allowed together with option -linearize" 
		if $config_file->lst_file();
	die "Option -update_derivatives is only allowed together with option -linearize" 
		if $config_file->update_derivatives();
	die "Option -error is only allowed together with option -linearize" 
		if $config_file->error();
	die "Option -error_code is only allowed together with option -linearize" 
		if $config_file->error_code();
	die "Option -derivatives_data is only allowed together with option -linearize" 
		if $config_file->derivatives_data();
}


my $direction = $config_file -> search_direction;
die "You need to specify a search direction (forward/backward/both)\n" unless (defined $direction );
my $eval_string = common_options::model_parameters(\%options);
my $models_array = [ model -> new ( eval $eval_string,
									filename           => $config_file -> model) ] ;

if( $options{'shrinkage'} ) {
	$models_array->[0] -> shrinkage_stats( enabled => 1 );
}

if( $models_array->[0] -> is_option_set( record => 'abbreviated', name => 'REPLACE' ) ){
    print "\nWARNING: Option REPLACE used in \$ABBREVIATED. This can lead to serious errors.\n\n";
}
my $scm;

if( $direction eq 'forward' or $direction eq 'both' ){
	ui -> print( category => 'scm',
				 message => "Starting scm forward search" );


	my $orig_ofv;
	my $orig_p_value;
	my $ofv_backward=undef;
	my $p_backward=undef;
	if( -e $options{'config_file'} ){
		
		if( defined $config_file -> ofv_forward ){
			$orig_ofv = $config_file -> ofv_change;
			$config_file -> ofv_change($config_file -> ofv_forward);
		}
		
		if( defined $config_file -> p_forward ){
			$orig_p_value = $config_file -> p_value;
			$config_file -> p_value( $config_file -> p_forward );
		}

		if( defined $config_file -> ofv_backward ){
			$ofv_backward = $config_file -> ofv_backward ;
		}elsif (defined $orig_ofv){
			$ofv_backward = $orig_ofv;
		}

		if( defined $config_file -> p_backward ){
			$p_backward = $config_file -> p_backward;
		}elsif (defined $orig_p_value){
			$p_backward = $orig_p_value;     
		}
	}
	
	$config_file -> search_direction( 'forward' );

	$scm = tool::scm -> 
		new ( eval( $common_options::parameters ),
			  models	=> $models_array,
			  config_file => $config_file,
			  both_directions => ($direction eq 'both')? 1 : 0,
			  p_backward => $p_backward,
			  ofv_backward => $ofv_backward);
	
	$scm-> print_options (cmd_line => $cmd_line,
						  toolname => 'scm',
						  local_options => [keys %optional_options],
						  common_options => \@common_options::tool_options);

	#copy config file to rundir
	my ( $dir, $file ) = OSspecific::absolute_path('',$options{'config_file'});
	cp($dir.$file,$scm->directory().$file);

	$scm -> run;
	
	if( -e $options{'config_file'} ){
		if( defined $orig_ofv ){
			$config_file -> ofv_change( $orig_ofv );
		}
		
		if( defined $orig_p_value ){
			$config_file -> p_value( $orig_p_value );
		}

		if( defined $scm -> base_criteria_values ){
			$config_file -> base_criteria_values( $scm -> base_criteria_values );
		}

		if( defined $scm -> included_relations ){
			$config_file -> included_relations( $scm -> included_relations );
		}
	}
}

if( $direction eq 'backward' ){
	
	if( -e $options{'config_file'} ){
		if( defined $config_file -> ofv_backward ){
			$config_file -> ofv_change( $config_file -> ofv_backward );
		}

		if( defined $config_file -> p_backward ){
			$config_file -> p_value( $config_file -> p_backward );
		}
		
	}

	$config_file -> search_direction( 'backward' );

	my $scm_back = tool::scm -> 
		new ( eval( $common_options::parameters ),
			  directory   => $options{'directory'},
			  models	=> $models_array,
			  config_file => $config_file );


	ui -> print( category => 'scm',
				 message => "Starting scm backward search" );
	
	$scm_back-> print_options (cmd_line => $cmd_line,
							   toolname => 'scm',
							   local_options => [keys %optional_options],
							   common_options => \@common_options::tool_options);

	#copy config file to rundir
	my ( $dir, $file ) = OSspecific::absolute_path('',$options{'config_file'});
	cp($dir.$file,$scm_back->directory().$file);


	$scm_back -> run;

}

ui -> print( category => 'scm',
			 message => "scm done\n" );
