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
use tool::modelfit;
use model;
use common_options;
use ui;
use Cwd;

my $cmd_line = $0 . " " . join( " ", @ARGV );

my %options;

my %required_options = (  "reg_model:s" => undef,
						  "base_model:s"=> undef,
						  "mi_model:s"=> undef
    );
my %optional_options = ("sim_model:s" => undef,
						'alt_models:s'=> undef,
						"imputations:i" => undef,
						"samples:i" => undef,
						"chain_models:s" => undef);

my $res = GetOptions( \%options,
					  @common_options::get_opt_strings,
					  keys(%required_options),
					  keys(%optional_options) );
exit unless $res;

common_options::setup( \%options, 'mimp' ); #calls set_globals etc, initiates random sequence


my %help_text;

$help_text{Pre_help_message} = <<'EOF';
<h3 class="heading1">mimp</h3>

    Multiple imputation using PsN.

	EOF

    $help_text{Description} = <<'EOF';
<h3 class="heading1">Description:</h3>

    Multiple imputation
	EOF

	$help_text{-alt_models} = <<'EOF';
<p class="style2">-alt_models='string'</p>
    Alternative models, comma-separated list.
	EOF


	$help_text{-sim_model} = <<'EOF';
<p class="style2">-sim_model='string'</p>
    Simulation model
	EOF

	$help_text{-reg_model} = <<'EOF';
<p class="style2">-reg_model='string'</p>
    Regression model
	EOF

	$help_text{-frac_model} = <<'EOF';
<p class="style2">-frac_model='string'</p>
    Fraction model
	EOF

	$help_text{-base_model} = <<'EOF';
<p class="style2">-base_model='string'</p>
    Base model
	EOF
	$help_text{-mi_model} = <<'EOF';
<p class="style2">-mi_model='string'</p>
    Multiple imputation model.
	EOF

	$help_text{-samples} = <<'EOF';
-samples=N

    Number of samples.
	EOF

	$help_text{Post_help_message} = <<'EOF';
EOF

	common_options::online_help( 'mimp', \%options, \%help_text, \%required_options, \%optional_options);

unless ( defined $options{'base_model'} ){
	print "base_model must be given\n" ;
	exit;
}
unless ( defined $options{'reg_model'} ){
	print "reg_model must be given\n" ;
	exit;
}
unless ( defined $options{'mi_model'} ){
	print "mi_model must be given\n" ;
	exit;
}

my $nimp=6; #default
if ( defined $options{'imputations'} ){
	$nimp=$options{'imputations'};
}
if ( defined $options{'sim_model'}){
	if (not defined $options{'samples'}){
		print "samples must be given when sim_model is used\n" ;
		exit;
	}
}else{
	if (defined $options{'samples'}){
		print "samples must not be given when sim_model is not used\n" ;
		exit;
	}
	$options{'samples'}=1;
}

## Set the automatic renaming of modelfit directory
if ( !$options{'directory'}) {
	my $dirnamebase = 'mimp_dir';
	my $i = 1;
	while(-e $dirnamebase."$i") {$i++};
	my $dirname = $dirnamebase."$i";
	$options{'directory'} = $dirname;
}

my ($newdir, $newfile) = OSspecific::absolute_path( $options{'directory'}, '' );
unless (-e $newdir){
	mkdir( $newdir );
}
($newdir, $newfile) = OSspecific::absolute_path( $options{'directory'} .  '/m1', '' );
unless (-e $newdir){
	mkdir( $newdir );
}

my $sim;
my $eval_string = common_options::model_parameters(\%options);
my $ignore_missing_base_data = 0;
$ignore_missing_base_data = 1 if (defined $options{'sim_model'});

$sim = model -> new ( eval( $eval_string ),
					  filename                    => $options{'sim_model'},
					  ignore_missing_output_files => 1 ) if (defined $options{'sim_model'});

my $mi = model -> new ( eval( $eval_string ),
						filename                    => $options{'mi_model'},
						ignore_missing_output_files => 1 ,
						ignore_missing_data => 1 );

my $base = model -> new ( eval( $eval_string ),
						  filename                    => $options{'base_model'},
						  ignore_missing_output_files => 1,
						  ignore_missing_data => $ignore_missing_base_data);

my $reg = model -> new ( eval( $eval_string ),
						 filename                    => $options{'reg_model'},
						 ignore_missing_output_files => 1,
						 ignore_missing_data => 1);
my @alternatives;
if (defined $options{'alt_models'}){
	foreach my $altfile (split(/,/,$options{'alt_models'})){
		push(@alternatives, model -> new ( eval( $eval_string ),
										   filename                    => $altfile,
										   ignore_missing_output_files => 1,
										   ignore_missing_data => 1));
	}
}
my @chain_models;
if (defined $options{'chain_models'}){
	foreach my $chainfile (split(/,/,$options{'chain_models'})){
		push(@chain_models, model -> new ( eval( $eval_string ),
										   filename                    => $chainfile,
										   ignore_missing_output_files => 1,
										   ignore_missing_data => 1));
	}
}

chdir($newdir);

##############################
# sim model
############################

my @simdatanames;
if (defined $options{'sim_model'}){
	my $simulation_models;
	my $datafilesref;
	for(my $sample=1; $sample<= $options{'samples'}; $sample++){
		my $sim_name='sim_'.$sample.'.mod';
		my $sim_model = $sim -> copy( filename    => $sim_name,
									  copy_datafile   => ($sample == 1), #if first sample then copy, otherwise not
									  write_copy => 0,
									  copy_output => 0);
		if ($sample == 1){
			$datafilesref = $sim_model->datafiles(absolute_path => 1);
		}else{
			$sim_model->datafiles(new_names => $datafilesref);
		}

		#set seed
		my $prob = $sim_model -> problems -> [0];
		my $sim_record = $sim_model -> record( problem_number => 1,
											   record_name => 'simulation' );
		
		my @new_record;
		foreach my $sim_line ( @{$sim_record -> [0]} ){
			my $new_line;
			while( $sim_line =~ /([^()]*)(\([^()]+\))(.*)/g ){
				my $head = $1;
				my $old_seed = $2;
				$sim_line = $3;
				$new_line .= $head;
				
				while( $old_seed =~ /(\D*)(\d+)(.*)/ ){
					$new_line .= $1;
					$new_line .= random_uniform_integer( 1, 0, 1000000 ); # Upper limit is from nmhelp 
					$old_seed = $3;
				}
				
				$new_line .= $old_seed;
				
			}
			
			push( @new_record, $new_line.$sim_line );
		}
		
		$prob -> set_records( type => 'simulation',
							  record_strings => \@new_record );
		
		
		#set $TABLE FILE
		my $fname='start_'.$sample.'_out.dta';
		push (@simdatanames,$fname);
		$sim_model -> set_option( record_name  => 'table',
								  problem_numbers => [(1)],
								  record_number => 1,
								  option_name  => 'FILE',
								  option_value => $fname);
		
		$sim_model -> _write();
		push( @{$simulation_models}, $sim_model );
	}


	my $mod_sim = tool::modelfit -> new( 
		%{common_options::restore_options(@common_options::tool_options)},
		top_tool         => 0,
		models           => $simulation_models,
		base_directory   => '..',
		directory        => '../simulation_dir1', 
		logfile	         => undef,
		raw_results           => undef,
		prepared_models       => undef,
		copy_data  => 0);
	
	$mod_sim-> print_options (cmd_line => $cmd_line,
							  directory =>'../',
							  toolname => 'mimp',
							  local_options => [keys %optional_options],
							  common_options => \@common_options::tool_options);

	print "Running ".$options{'samples'}." simulation models\n";    
	$mod_sim -> run;

	$simulation_models=undef;
	$mod_sim = undef;
}

##########################
#base model
##########################

my $base_models;
my @basedatanames;
my $datafilesref;
for(my $sample=1; $sample<= $options{'samples'}; $sample++){
	my $base_name='base_'.$sample.'.mod';
	my $base_model = $base -> copy( filename    => $base_name,
									copy_datafile   => ((not defined $options{'sim_model'}) and ($sample == 1)), #copy if first sample and no sim_model
									write_copy => 0,
									copy_output => 0);

	my $fname;
	if (scalar(@simdatanames)>0){
		#set $DATA
		$fname = $simdatanames[($sample-1)];
		$base_model -> datafiles(new_names => [$fname] );
	}else{
		if ($sample == 1){
			$datafilesref = $base_model->datafiles(absolute_path => 1); #this datafile is in mimp dir
		}else{
			$base_model->datafiles(new_names => $datafilesref);
		}
	}
	#set $TABLE FILE
	$fname='base_'.$sample.'_out.dta';
	push (@basedatanames,$fname);
	$base_model -> set_option( record_name  => 'table',
							   problem_numbers => [(1)],
							   record_number => 1,
							   option_name  => 'FILE',
							   option_value => $fname);
	
	$base_model -> _write();
	push( @{$base_models}, $base_model );
}


#run
my $mod_base = tool::modelfit -> new( 
	%{common_options::restore_options(@common_options::tool_options)},
	top_tool         => 0,
	models           => $base_models,
	base_directory   => '..',
	directory        => '../base_dir1', 
	logfile	         => undef,
	raw_results           => undef,
	prepared_models       => undef,
	copy_data => 0);

print "Running ".$options{'samples'}." base models\n";    
$mod_base -> run;
$base_models=undef;
$mod_base = undef;



#sim base optional-frac optional-wt reg mi

##########################
#all chain model
##########################


my @next_input_datanames = @basedatanames;
my @this_input_datanames;
my $chain_number=0;
foreach my $chain_mod (@chain_models){
	$chain_number++;
	@this_input_datanames = @next_input_datanames;
	@next_input_datanames = ();
	my $chain_model_copies;
	
	for(my $sample=1; $sample<= $options{'samples'}; $sample++){
		my $chain_name='chain-'.$chain_number.'_'.$sample.'.mod';
		my $chain_model = $chain_mod -> copy( filename    => $chain_name,
											  copy_datafile   => 0,
											  write_copy => 0,
											  copy_output => 0);
		
		#set $DATA
		my $fname = $this_input_datanames[($sample-1)];
		$chain_model -> datafiles(new_names => [$fname] );
		
		#set $TABLE FILE
		$fname='chain-'.$chain_number.'_'.$sample.'_out.dta';
		push (@next_input_datanames,$fname);
		$chain_model -> set_option( record_name  => 'table',
									problem_numbers => [(1)],
									record_number => 1,
									option_name  => 'FILE',
									option_value => $fname);
		
		$chain_model -> _write();
		push( @{$chain_model_copies}, $chain_model );
	}
	
	#run
	my $mod_chain = tool::modelfit -> new( 
		%{common_options::restore_options(@common_options::tool_options)},
		top_tool         => 0,
		models           => $chain_model_copies,
		base_directory   => '..',
		directory        => '../chain_dir'.$chain_number, 
		logfile	         => undef,
		raw_results           => undef,
		prepared_models       => undef,
		copy_data =>0);
	
	print "Running ".$options{'samples'}." chain model number $chain_number\n";    
	$mod_chain -> run;
	$chain_model_copies=undef;
	$mod_chain = undef;
}


##############################
# reg model
############################


my $reg_models;
my @regdatanames;


for(my $sample=1; $sample<= $options{'samples'}; $sample++){
	my $reg_name='reg_'.$sample.'.mod';
	my $reg_model = $reg -> copy( filename    => $reg_name,
								  copy_datafile   => 0,
								  write_copy => 0,
								  copy_output => 0);

	#set $DATA
	my $fname = $next_input_datanames[($sample-1)];
	$reg_model -> datafiles(new_names => [$fname] );

	#set $TABLE FILE
	$fname='reg_'.$sample.'_out.dta';
	push (@regdatanames,$fname);
	$reg_model -> set_option( record_name  => 'table',
							  problem_numbers => [(1)],
							  record_number => 1,
							  option_name  => 'FILE',
							  option_value => $fname);

	$reg_model -> _write();
	push( @{$reg_models}, $reg_model );
}


#run
my $mod_reg = tool::modelfit -> new( 
	%{common_options::restore_options(@common_options::tool_options)},
	top_tool         => 0,
	models           => $reg_models,
	base_directory   => '..', ##??
	directory        => '../reg_dir1', 
	logfile	         => undef,
	raw_results           => undef,
	prepared_models       => undef,
	copy_data =>0);

print "Running ".$options{'samples'}." regression models\n";    
$mod_reg -> run;
$reg_models=undef;
$mod_reg = undef;


##########################
#loop alternative models
##########################

my $altindex = 0;
foreach my $alt (@alternatives){
	$altindex++;

	my $alt_models;

	for(my $sample=1; $sample<= $options{'samples'}; $sample++){
		my $alt_name='alt-'.$altindex.'_'.$sample.'.mod';
		my $alt_model = $alt -> copy( filename    => $alt_name,
									  copy_datafile   => 0,
									  write_copy => 0,
									  copy_output => 0);

		#set $DATA
		my $fname = $regdatanames[($sample-1)];
		$alt_model -> datafiles(new_names => [$fname] );

		$alt_model -> _write();
		push( @{$alt_models}, $alt_model );
	}

	#run
	my $mod_alt = tool::modelfit -> new( 
		%{common_options::restore_options(@common_options::tool_options)},
		top_tool         => 0,
		models           => $alt_models,
		base_directory   => '..', ##??
		directory        => '../alt_dir'.$altindex, 
		logfile	         => undef,
		raw_results           => undef,
		prepared_models       => undef,
		copy_data => 0);
    
	print "Running ".$options{'samples'}." alt models for alternative $altindex\n";    
	$mod_alt -> run;
	$alt_models=undef;
	$mod_alt = undef;
}


##############################
# loop mi model
############################


for (my $j=1; $j<=$nimp; $j++){
	my $mi_models;
	for(my $sample=1; $sample<= $options{'samples'}; $sample++){
		my $mi_name='mi-'.$j.'_'.$sample.'.mod';
		my $mi_model = $mi -> copy( filename    => $mi_name,
									copy_datafile   => 1,
									write_copy => 0,
									copy_output => 0);

		#set $DATA
		my $fname = $regdatanames[($sample-1)];
		$mi_model -> datafiles(new_names => [$fname] );
		#PROB 1!!!

		#set seed i first PROB
		#set seed
		my $prob = $mi_model -> problems -> [0];
		my $sim_record = $mi_model -> record( problem_number => 1,
											  record_name => 'simulation' );
		my @old_lines;
		if (defined $sim_record -> [0] and scalar(@{$sim_record -> [0]})>0){
			@old_lines = @{$sim_record -> [0]};
		}else{
			@old_lines =('(12345)'); #no old sim record
		}
		my @new_record;
		
		foreach my $sim_line ( @old_lines){
			my $new_line;
			while( $sim_line =~ /([^()]*)(\([^()]+\))(.*)/g ){
				my $head = $1;
				my $old_seed = $2;
				$sim_line = $3;
				$new_line .= $head;
				
				while( $old_seed =~ /(\D*)(\d+)(.*)/ ){
					$new_line .= $1;
					$new_line .= random_uniform_integer( 1, 0, 1000000 ); # Upper limit is from nmhelp 
					$old_seed = $3;
				}
				
				$new_line .= $old_seed;
				
			}
			push( @new_record, $new_line.$sim_line );
		}
		
		$prob -> set_records( type => 'simulation',
							  record_strings => \@new_record );
		$mi_model -> _write();
		push( @{$mi_models}, $mi_model );
	}
	my $mod_mi = tool::modelfit -> new( 
		%{common_options::restore_options(@common_options::tool_options)},
		top_tool         => 0,
		models           => $mi_models,
		base_directory   => '..', ##??
		directory        => '../mi_dir'.$j, 
		logfile	         => undef,
		raw_results           => undef,
		prepared_models       => undef,
		seed       => random_uniform_integer(1,1,99999999),
		copy_data => 0);
	
	print "Running ".$options{'samples'}." mi models copy $j\n";    
	
	$mod_mi -> run;
	$mod_mi = undef;
	$mi_models = undef;

}
#run
print "\nmimp done\n";
