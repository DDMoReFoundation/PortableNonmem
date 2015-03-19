#!perl.exe
use FindBin qw($Bin);
use lib "$Bin/../site/lib/PsN_4_3_1";
# the above was entered by psnGlobalToLocalPaths

use PsN;
use model;
use output;
use Getopt::Long;
use File::Copy qw/cp mv/;
use common_options;
use Math::Random;

sub search_record {
  #input is string $row and array ref $list
  #$row has no leading spaces nor $ 
  my $row = shift;
  my $reclist=shift;
  my $found = 0;

  foreach my $rec (@{$reclist}){
    if ($row =~ /^($rec)/){
      $found = $rec;
      last;
    }
  }
  return $found;

}

my %options;
my %required_options =();
my %optional_options = (
    'h|?'                       => undef,
    'help'                      => undef,
	"output_model:s" => undef,
	"from_model:s" => undef,
	"ignore_missing_parameters" => undef,
	"comment:s" => undef,
	"degree:f" => undef,
	"add_tags" => undef,
	"diagonal_dominance" => undef,
	"add_prior:s" => undef,
	"seed:s" => undef,
	"based_on:i" => undef,
	"renumber:i" => undef,
	);

my $res = GetOptions( \%options,
					  keys(%optional_options) );


unless (defined $options{'seed'}){
	$options{'seed'} = random_uniform_integer( 1, 100000, 999999 );
}
random_set_seed_from_phrase( $options{'seed'} ) if ( defined $options{'seed'} );
#setup would set degree and initiate tweaking

exit unless $res;

my %help_text;

$help_text{Pre_help_message} = <<'EOF';
    update_inits

    Update a model file with final estimates from NONMEM output.
EOF
    1;
$help_text{Options} = <<'EOF';      
Options:

    The options are given here in their long form. Any option may be
    abbreviated to any nonconflicting prefix. 
    
    The following options are valid:
EOF
    1;
$help_text{-h} = <<'EOF';
-h | -?
      
    With -h or -? update_inits will print a list of options and exit.
EOF
    1;
$help_text{-help} = <<'EOF';      
-help
      
    With -help update_inits will print this, longer, help message.
EOF
    1;
$help_text{-output_model} = <<'EOF';
-output_model=file

    The name of the model file to create. If this options is omitted, a copy of
	the original model file with extension .org is created, and the original 
	file is modified.
EOF
    1;
$help_text{-ignore_missing_parameters} = <<'EOF';
-ignore_missing_parameters
	Default not set
	
	If set, update_inits will not require a 1-to-1 matching of parameter names 
	and indexes between the model to update and the source 	of new estimates 
	(lst-file or other model file).
EOF
    1;
$help_text{-from_model} = <<'EOF';
-from_model=filename
	Default not used

    The name of a model file to copy initial estimates from, instead of a lst-file. 
	Cannot be used together with a named lst-file on the command-line.
EOF
    1;
$help_text{-comment} = <<'EOF';
-comment=text
    Default not used.

	If the option is used, a new line with <text> will be inserted 
	directly following the $PROBLEM row.
	The comment text must be enclosed with quotes (double quotes on Windows) 
	if it contains spaces.
EOF
    1;
$help_text{-degree} = <<'EOF';
-degree=fraction
    Default not set

	After updating the initial estimates in the output file, randomly
	perturb them by degree=fraction, i.e. change estimate to a value
	randomly chosen in the range estimate +/- estimate*fraction while
	respecting upper and lower boundaries, if set in the model file.
	Degree is set to 0.1, a 10% perturbation, when option tweak_inits is set in execute.
EOF
1;    
$help_text{-add_tags} = <<'EOF';
-add_tags
    Default not set

	Add all runrecord tags, see runrecord user guide. update_inits will not check if any tags 
	are already present.
EOF
1;    
$help_text{-diagonal_dominance} = <<'EOF';
-diagonal_dominance
    Default not set

	NONMEM sometimes prints OMEGA or SIGMA matrices
	in the lst-file which are not positive definite, and the 
	diagonal_dominance option offers a way to fix this.
	If option is set then PsN will ensure that OMEGA
	and SIGMA are strictly diagonally dominant by decreasing off-diagonal
	elements if necessary. This in turn guarantees that OMEGA and SIGMA 
	are positive definite.  However, the perturbation made by PsN is 
	most likely not the smallest perturbation 
	required to make OMEGA/SIGMA positive definite.
EOF
1;    
$help_text{-add_prior} = <<'EOF';
-add_prior=df
    Default not set

	Add $PRIOR NWPRI based on the NONMEM output. Will automatically read
	estimates and covariances from output and use them to define the 
	prior. df should be the degrees of freedom, a comma-separated list
	with one integer per omega block.
	This feature is highly experimental, and you must check $PRIOR 
	in the new model file manually before using it.
	Option -add_prior cannot be used together with option -from_model. 
EOF
1;    
$help_text{-seed} = <<'EOF';
-seed=some string

    The random seed for perturbation if option -degree is set. 
EOF
1;    
$help_text{-based_on} = <<'EOF';
 -based_on=number

    If the -based_on option is used, update_inits will set 
	the runrecord 'Based on' tag (if present, or if option -add_tags is used) 
	to that number. If option -based_on is not used, update_inits will by default try to extract 
	a run number from the original model file name and use that instead.
	If a number cannot be extracted then nothing will be set. 
EOF
1;    
$help_text{-renumber} = <<'EOF';
-renumber='new number'

    Default extracted from the -output_model file name.	If -output_model=runY.mod 
	is set where Y is a number then -renumber=Y will be set automatically.
	All FILE names in $TABLE records that end with tab'any number' 
	or tab'any number'.csv will get 'any number' replaced with
	'new number', provided that 'new number' is not 0.
	If 'filename' in MSFO='filename' in the  $ESTIMATION record
	ends with a number, that number will be replaced by 'new number'.

	Set option -renumber=0 to prevent renumbering in $TABLE and $EST.
EOF
1;    

common_options::online_help( 'update_inits', \%options, \%help_text, \%required_options, \%optional_options);

if ( scalar( @ARGV ) < 1 ){
  print "A model file must be specified. Use 'update_inits -h' for help.\n";
  exit;
}

my $ignore_missing_parameters=0;
if ( defined $options{'ignore_missing_parameters'} ){
	$ignore_missing_parameters=1;
}


unless( $ARGV[0] ){
	die "You must at least enter a model file name\n";
}
my $run_number;
#extract run number
if ($ARGV[0]){
	my $tmp = $ARGV[0];
	if ($tmp =~ /(run|Run|RUN)([0-9]+[^0-9]*)\./){
		$run_number = $2;
	}  
}

unless( -e $ARGV[0] ){
	die "No such file: $ARGV[0]\n";
}


my $tablenum;
my $auto_renumber=0;
if (defined $options{'renumber'}) {
	$tablenum=$options{'renumber'} if ($options{'renumber'} != 0);
}elsif( $options{'output_model'} ){
	my $tmp = $options{'output_model'};
	if ($tmp =~ /(run|Run|RUN)([0-9]+)[^0-9]*\./){
		$tablenum = $2;
		$options{'renumber'}=$tablenum;
		$auto_renumber=1;
	}  
}

my @record_list=('THETA','OMEGA','SIGMA');
print "Updating records ".join(' ',@record_list)."\n";
print "and renumbering table and msfo files (set -renumber=0 to avoid this)\n" if ($auto_renumber);

if( $ARGV[1] && $options{'from_model'}){
	die "Ambiguous input: Cannot specify both lst-file and from_model.\n";
}

if( $options{'add_prior'})  {
	push(@record_list,'PRI');
	die "Cannot specify both -add_prior and -from_model.\n" if($options{'from_model'});
}



my $ignore_missing_files=1;
$ignore_missing_files = 0 unless ( $ARGV[1] );
my $model = model -> new ( filename => $ARGV[0],
						   ignore_missing_files => $ignore_missing_files,
						   ignore_missing_data =>1);
my $model_copy = model -> new ( filename => $ARGV[0],
								ignore_missing_files => 1,
								ignore_missing_data=>1);

if ( scalar (@{$model-> problems}) != 1 ){
	die 'Script can only handle modelfiles with exactly one problem.\n';
}


my $outfile;

if ( $options{'output_model'} ){
	$outfile = $options{'output_model'};
}  else {
	#original file will be overwritten, copy to .org
	cp( $ARGV[0], $ARGV[0].'.org' );
	unlink($ARGV[0]);
	$outfile = $ARGV[0];
}

if (defined $options{'from_model'}) {
	die "No such file: ".$options{'from_model'}."\n" unless (-e $options{'from_model'});
	my $params_model = model -> new ( filename => $options{'from_model'},
									  ignore_missing_files => 1,
									  ignore_missing_data=>1);

	my $array = $params_model->get_hash_values_to_labels();

	my $check = 0;
	$check = $options{'diagonal_dominance'} if (defined $options{'diagonal_dominance'});
	for (my $i=0; $i< scalar(@{$model_copy->problems}); $i++){
		last if ($i >= scalar(@{$array}));
		$model_copy -> update_inits( from_hash => $array->[$i],
									 problem_number => ($i+1),
									 ensure_diagonal_dominance => $check,
									 ignore_missing_parameters => $ignore_missing_parameters );
	}

} else { 
	my $output;
	if( $ARGV[1] ){
		$output = output -> new( filename => $ARGV[1],
								 ignore_missing_files => 0);

		unless( $output ){
			die "No such file: $ARGV[1]\n";
		}
		unless ($output->parsed_successfully()){
			die "Failed to parse $ARGV[1]: ".$output -> parsing_error_message();
		}
	}elsif( defined $model->outputs and -e $model ->outputs -> [0] -> filename ){
		$output = $model -> outputs -> [0];
		unless ($output->parsed_successfully()){
			die "Failed to parse ".$model ->outputs -> [0] -> filename.": ".
				$output -> parsing_error_message();
		}
	} else {
		die "No file to read parameter values from\n";
	}

	my $check = 0;
	$check = $options{'diagonal_dominance'} if (defined $options{'diagonal_dominance'});
	$model_copy -> update_inits( from_output => $output,
								 ensure_diagonal_dominance => $check,
								 ignore_missing_parameters => $ignore_missing_parameters );

}
$model_copy -> filename( $outfile );

if (defined $options{'degree'}){
	foreach my $prob ( @{$model_copy->problems()}) {
		$prob -> set_random_inits ( degree => $options{'degree'} );
	}
}

if ($options{'add_prior'}){
	$model_copy -> problems()->[0]->add_prior_distribution(from_output => $output,
														   problem_number => 1,
														   df_string => $options{'add_prior'});
}	


if (defined $options{'renumber'} and $options{'renumber'} != 0){
	for (my $j=0; $j< scalar(@{$model_copy->problems}); $j++){
		#handle table
		if (defined $model_copy->problems->[$j]->tables){
			foreach my $tab (@{$model_copy->problems->[$j]->tables}){
				$tab->renumber_file (numberstring => $tablenum);
			}
		}
		#handle estimation
		if (defined $model_copy->problems->[$j]->estimations){
			foreach my $est (@{$model_copy->problems->[$j]->estimations}){
				$est->renumber_msfo (numberstring => $tablenum);
			}
		}
	}
}	
#handle PROBLEM update_tags add_tags add_comment
my $based_on = $run_number;
$based_on = $options{'based_on'} if (defined $options{'based_on'});

if (defined $based_on or defined $options{'comment'} or defined $options{'add_tags'}){
	$model_copy->problems ->[0]->problems->[0]->update_runrecord_tags(based_on =>$based_on,
																	  new_comment =>$options{'comment'},
																	  add_tags => (defined $options{'add_tags'}));
}
$model_copy -> _write(number_format => $options{'sigdig'},
					  local_print_order => 1);







