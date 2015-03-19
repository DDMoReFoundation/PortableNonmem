#!perl.exe
use FindBin qw($Bin);
use lib "$Bin/../site/lib/PsN_4_3_1";
# the above was entered by psnGlobalToLocalPaths

# Perl includes #
use Config;
use strict;
use Getopt::Long;
# External modules #
use Math::Random;
# PsN includes #
use PsN;
use ui;
use common_options;
use Cwd;
use model;
use tool::pvar;

my $cmd_line = $0 . " " . join( " ", @ARGV );
my %options;

my %required_options = (
	"parameters:s" => undef,
);

my %optional_options = (
	"samples:i" => undef,
	"models" => undef,
);

my $res = GetOptions( \%options,
					  @common_options::get_opt_strings,
						keys(%required_options),
					  keys(%optional_options) );

exit unless $res;

common_options::setup( \%options, 'pval' ); #calls set_globals etc, initiates random sequence

my %help_text;

$help_text{-samples} = <<'EOF';
      Number of simulated datasets to generate.
      Default 100.
EOF

$help_text{-parameters} = <<'EOF';
      Comma separated list of parameter to investigate.
			Mandatory.
EOF

$help_text{-models} = <<'EOF';
      Expect a list of models as command arguments instead of an scm logfile.
			Optional.
EOF

common_options::online_help('pvar', \%options, \%help_text, \%required_options, \%optional_options);

if (not defined $options{'samples'}) {
	$options{'samples'} = 100;
}

if (not defined $options{'parameters'}) {
	die "Option -parameters is required.";
}

# Collect and check the mandatory arguments
my @model_files;

if ($options{'models'}) {
	foreach my $arg (@ARGV) {
		push @model_files, $arg;
	}
	if (@model_files == 0) {
		die("Must specify at least one model file when model option is set");
	}
} else {
	my $scm_logfile = $ARGV[0];
	if (not defined $scm_logfile or defined $ARGV[1]) {
		die("Must specify one and only one scm logfile");
	}
	@model_files = tool::pvar->get_models_from_scm_directory($scm_logfile);
}

my @parameters = split(',', $options{'parameters'});

# Create the model objects
my @models;
my $eval_string = common_options::model_parameters(\%options);

foreach my $model_name (@model_files) {
	push(@models, model->new(eval($eval_string),
			filename => $model_name,
			ignore_missing_data => 1,
		));
}

if (not $options{'models'}) {
	tool::pvar->set_data_files(@models);
}

my $dummy_model = model->create_dummy_model;

my $pvar = tool::pvar->new(eval($common_options::parameters),
	samples => $options{'samples'},
	parameters => \@parameters,
	models => [ $dummy_model ],
	pvar_models => \@models);

$pvar->print_options (cmd_line => $cmd_line,
		      toolname => 'PVAR',
		      local_options => [keys %optional_options],
		      common_options => \@common_options::tool_options);

$pvar->run;

print "pvar done\n";
