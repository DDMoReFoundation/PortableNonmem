#!perl.exe
use FindBin qw($Bin);
use lib "$Bin/../site/lib/PsN_4_3_1";
# the above was entered by psnGlobalToLocalPaths

use PsN;
use file;
use model;
use tool::scm;
use tool::modelfit;
use strict;
use Getopt::Long;
use Cwd;
use common_options;
use ui;
use OSspecific;
use File::Path 'rmtree';
use File::Copy qw/cp mv/;

my $cmd_line = $0 . " " . join( " ", @ARGV );

my %options;

my %required_options = ();

my %optional_options = ("epsilon!" => '',
			"foce!" => '',
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

  Linearize model

  <h3 class="heading1">Usage:</h3>
EOF

    $help_text{Description} = <<'EOF';
<style type="text/css">
<!--
.style5 {font-family: "Courier New", Courier, monospace; font-weight: bold; font-size: 14px; }
-->
</style>
  <h3 class="heading1">Description:</h3>

    Linearize

EOF

    $help_text{Options} = <<'EOF';
  <h3 class="heading1">Options:</h3>

    The options are given here in their long form. Any option may be
    abbreviated to any nonconflicting prefix.

    The following options are valid:
EOF

    $help_text{-h} = <<'EOF';
    <p class="style2">-h | -?</p>

    With -h or -? linearize will print a list of options and exit.
EOF

    $help_text{-help} = <<'EOF';
    <p class="style2">-help</p>

    With -help linearize will print this, longer, help message.
EOF

    $help_text{-foce} = <<'EOF';
    <p class="style2">-foce</p>

    Set by default. Expand around 
    conditional ETA estimates instead of around ETA=0.    
EOF
    $help_text{-error} = <<'EOF';
    <p class="style2">-error</p>

    Only relevant if -no-epsilon is set. 
    Use an approximated linearization of the error model instead of an exact.

    Alternatives are add (for additive), prop (for proportional) or
    propadd (for proportional plus additive).
    The error model must be defined in a particular way when this option is used,
    see the scm userguide for details.
EOF
    $help_text{-epsilon} = <<'EOF';
    <p class="style2">-epsilon</p>

    Linearize with respect to epsilons,
    set by default. Disable with -no-epsilon.
EOF

    $help_text{Post_help_message} = <<'EOF';
    Also see 'psn_options -h' for a description of common options.
EOF

common_options::online_help( 'linearize', \%options, \%help_text, \%required_options, \%optional_options);

#calls get_defaults, set_globals etc, initiates random sequence, store tool_options
common_options::setup( \%options, 'linearize' ); 


die "linearize only works with NONMEM7" unless ($PsN::nm_major_version == 7);

my $eval_string = common_options::model_parameters(\%options);

my $model = model -> new ( eval( $eval_string ),
						   filename                    => $ARGV[0],
						   ignore_missing_output_files => 1);

my $lstfile;
if (-e $model->outputs->[0]->full_name()){
    $lstfile = $model->outputs->[0]->full_name();
}

if( $model-> is_option_set( record => 'abbreviated', name => 'REPLACE' ) ){
    print "\nWARNING: Option REPLACE used in \$ABBREVIATED. This can lead to serious errors.\n\n";
}

my @keep;
foreach my $option (@{$model->problems->[0]->inputs->[0]->options()}){
    push ( @keep, $option->name() ) if ( not ($option -> value eq 'DROP' or $option -> value eq 'SKIP'
					      or $option -> name eq 'DROP' or $option -> name eq 'SKIP'
					      or $option->name eq 'ID' or $option->name eq 'DV' 
					      or $option->name eq 'MDV'));
}

#set do not drop to everything undropped in model

my $scm = tool::scm -> 
    new ( eval( $common_options::parameters ),
		  models	=> [$model],
		  epsilon => $options{'epsilon'},
		  foce => $options{'foce'},
		  do_not_drop => \@keep,
		  lst_file => $lstfile,
		  error=> $options{'error'},
		  search_direction => 'forward',
		  linearize => 1,
		  max_steps => 0,
		  test_relations         => {},
		  categorical_covariates => [],
		  continuous_covariates  => [],
		  both_directions => 0,
		  logfile =>['linlog.txt'],
		  directory_name_prefix => 'linearize');

$scm-> print_options (cmd_line => $cmd_line,
					  toolname => 'scm',
					  local_options => [keys %optional_options],
					  common_options => \@common_options::tool_options);



$scm -> run;

#cleanup
rmtree([ $scm->directory.'m1' ]);
rmtree([ $scm->directory.'final_models' ]);
unlink($scm->directory.'covariate_statistics.txt');
unlink($scm->directory.'relations.txt');
unlink($scm->directory.'short_scmlog.txt');
unlink($scm->directory.'original.mod');
unlink($scm->directory.'base_model.mod');
cp($scm->directory.$scm->basename.'.dta',$scm->basename.'.dta');
cp($scm->directory.$scm->basename.'.mod',$scm->basename.'.mod');


ui -> print( category => 'linearize',
	     message => "\nlinearize done\n" );
