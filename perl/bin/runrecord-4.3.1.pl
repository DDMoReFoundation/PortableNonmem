#!perl.exe
use FindBin qw($Bin);
use lib "$Bin/../site/lib/PsN_4_3_1";
# the above was entered by psnGlobalToLocalPaths

### Perl script that creates a modeling sequence summary
### Accepts five arguments
### -from        Run number to start processing from. Default is 1.
### -to          stop run number
### -res_file    Name of the results file
### -root        "root" name of the model files
### -mod_ext     model file extension
### -out_ext     ouput file extension
### -sep         separator between fields in output file
### -rsep        separator between comment rows read from the model file
###              This is pasted between rows -within fields- in the output file
### -max_lvl     Max number of model children levels
### -var         Wether omegas and sigmas should be reported as variances or sd. Default is 'no'.
##  -rse         Wether standard errors should be reported as relative SEs or not. The default is 'yes'.
### Example: modseq -root=run -mod_ext=mod -out_ext=lst -from=1 -to=10
### summarizes the output from files run1.mod to run10.mod with
### output files run1.lst to run10.lst

use PsN;
use model;
use strict;
use Getopt::Long;
use common_options;
use charnames ':full';
use Encode qw(encode decode);
use Time::Local;
use POSIX;

my $cmd_line = $0 . " " . join( " ", @ARGV );

## Configure the command line parsing
Getopt::Long::config("auto_abbrev");

my %options;
## Declare the options

my %required_options = ("to:i" => undef );
my %optional_options = ("h!"   => undef,
	"from:i" => undef, 
	"root:s" => undef,
	"res_file:s" => undef,
	"mod_ext:s" => undef,
	"out_ext:s"=> undef,
	"prefer_census_style!" => undef,
	"sep:s" => undef,
	"rsep:s" => undef,
	"var:s" => undef,
	"rse:s" => undef,
	"max_lvl:i" => undef);

my $res = GetOptions( \%options,
	@common_options::get_opt_strings,
	keys(%required_options),
	keys(%optional_options) );
exit unless $res;

common_options::setup( \%options, 'execute' ); #calls set_globals etc, initiates random sequence

my $eval_string = common_options::model_parameters(\%options);

## Display help if requested
if(defined $options{'h'} or defined $options{'help'}) {

	print <<'ENDHELP';

	runrecord

	Perl script for creating run records

	Usage:

	runrecord [ -h | -? ] [ -help ]
						[ -from= 'integer' ]
						[ -root= 'string' ]
						[ -res_file= 'string' ]
						[ -mod_ext= 'string' ]
						[ -out_ext= 'string' ]
						[ -sep= 'string' ]
						[ -rsep = 'string' ]
						[ -max_lvl = 'integer' ]
						[ -prefer_census_style ]            
						[ -var = 'string' ]       
						[ -rse = 'string' ]  
						-to='number'

ENDHELP

	if(defined $options{'help'} and not defined $options{'h'}) {
		print "Please refer to the RunRecord User Guide\n";
	}
	exit;
}


if( not defined $options{'to'} ){
	print "The option -to must be specified. Please use runrecord -h to see the available options.\n" ;
	exit;
}

my $root      = "run";
my $mod_ext   = "mod";
my $res_file  = "AAruninfo.txt";
my $out_ext   = "lst";
my $cen_sty   = 0;
my $sep       = ";";
my $rsep      = "";
my $max_lvl   = 14;
my $var       = "no";
my $rse       = "yes";
my $from      = 1;
my $h         = 0;

$root    = $options{'h'}                   if( defined $options{'h'} );
$root    = $options{'root'}                if( defined $options{'root'} );
$res_file= $options{'res_file'}            if( defined $options{'res_file'} );
$mod_ext = $options{'mod_ext'}             if( defined $options{'mod_ext'} );
$out_ext = $options{'out_ext'}             if( defined $options{'out_ext'} );
$cen_sty = $options{'prefer_census_style'} if( defined $options{'prefer_census_style'} );
$sep     = $options{'sep'}                 if( defined $options{'sep'} );
$rsep    = $options{'rsep'}                if( defined $options{'rsep'} );
$max_lvl = $options{'max_lvl'}             if( defined $options{'max_lvl'} );
$var     = $options{'var'}                 if( defined $options{'var'} );
$rse     = $options{'rse'}                 if( defined $options{'rse'} );
$from    = $options{'from'}                if( defined $options{'from'} );

my $to = $options{'to'};

# Store results in info
my %info;

my %parameter_names;

$parameter_names{'theta'}      = [];
$parameter_names{'omega'}      = [];
$parameter_names{'comega'}     = [];
$parameter_names{'sigma'}      = [];
$parameter_names{'setheta'}    = [];
$parameter_names{'seomega'}    = [];
$parameter_names{'sesigma'}    = [];
$parameter_names{'cvsethetas'} = [];
$parameter_names{'cvseomegas'} = [];
$parameter_names{'cvsesigmas'} = [];

for( my $run = $from; $run <= $to; $run++ ){
	next unless( -e $root.$run.".".$mod_ext and -e $root.$run.".".$out_ext);
	$info{$run}{'Run'} = $run;
	my $model;
	my $output;

	$model = model -> new(eval( $eval_string ),
		filename=>$root.$run.".".$mod_ext,
		ignore_missing_output_files => 1,
		ignore_missing_data => 1);

	my @outputs = defined $model -> outputs() ? @{$model -> outputs()} : ();
	my $have_output = 0;
	if( scalar @outputs > 0 and defined $outputs[0] ) {
		$output = $outputs[0];
		$have_output =1 if ($output -> parsed_successfully());
	}


	## This section creates the parameter names over which the parameter estimates are going to be reported.
	my $paramnames;

	foreach my $param ('theta','omega','sigma','setheta','seomega','sesigma') {

		my $params;
		#must have PsN-3.1.19 or later for get_values_to_labels on cvse* and c*

		if ($have_output){
			#get_values_to_labels only works on defined output and if successful parsing 
			if($param =~/^omega/ and $var eq 'no') {
				$params     = $model -> get_values_to_labels(category => 'comega');
			} elsif($param =~/^sigma/ and $var eq 'no') {
				$params     = $model -> get_values_to_labels(category => 'csigma');
			} elsif($param =~/^setheta/ and $rse eq 'yes') {
				$params     = $model -> get_values_to_labels(category => 'cvsetheta');
			} elsif($param =~/^seomega/ and $rse eq 'yes') {
				$params     = $model -> get_values_to_labels(category => 'cvseomega');
			} elsif($param =~/^sesigma/ and $rse eq 'yes') {
				$params     = $model -> get_values_to_labels(category => 'cvsesigma');
			} else {
				$params     = $model -> get_values_to_labels(category => $param);
			}
		}

		unless($param =~/^se/) {
			$paramnames = $model -> labels(parameter_type => $param);

			## Remove trailing spaces in parameter names
			my @tmp;
			foreach my $p (@{$paramnames->[0]}) {
				$p =~s/\s+$//;
				push @tmp,$p;
			}
			@{$paramnames->[0]} = @tmp;

		}  else {

			$paramnames = $model -> labels(parameter_type => 'theta') if $param =~/setheta/;
			$paramnames = $model -> labels(parameter_type => 'omega') if $param =~/seomega/;
			$paramnames = $model -> labels(parameter_type => 'sigma') if $param =~/sesigma/;      

			if($param =~/^se/) {
				## Prepend se after having removed trailing spaces
				my @tmp;
				foreach my $p (@{$paramnames->[0]}) {
					$p =~s/\s+$//;
					push @tmp,"se".$p;
				}
				@{$paramnames->[0]} = @tmp;
			} 

		}

		## Extraxt the values of interest.
		my %tmp = ();
		if ( defined $params and defined $params -> [0] and defined $params -> [0] -> [0] ) {
			for ( my $i = 0; $i < scalar @{$params -> [0] -> [0]}; $i++ ){
				$tmp{$paramnames->[0]->[$i]} = $params -> [0] -> [0] -> [$i];
				my $seen = 0;

				for( my $j = 0; $j < scalar @{$parameter_names{$param}}; $j++ ) {
					$seen = 1 if($paramnames->[0]->[$i] eq $parameter_names{$param}->[$j]);
				}
				push(@{$parameter_names{$param}} ,$paramnames->[0]->[$i]) unless($seen);
			}
		}
		$info{$run}{$param} = \%tmp;
	}

	## Extract information from the model object.
	my @problems = defined $model -> problems() ? @{$model -> problems()} : ();
	if( scalar @problems > 0 and defined $problems[0] ) {
		my $problem = $problems[0];
		my $datafiles = $model->datafiles(problem_numbers =>[1]); #first problem
		$info{$run}{'Datafile'} = $datafiles->[0] if (defined $datafiles);

		## Extract the extimation settings
		my @estimation_records = defined $problem -> estimations() ?
		@{$problem -> estimations()} : ();
		if( scalar @estimation_records > 0 ) {
			for(my $i = 0; $i <= $#estimation_records; $i++ ) {
				my $method = "";
				my $meth_options = "";
				foreach my $option ( defined $estimation_records[$i] -> options() ?
					@{$estimation_records[$i] -> options()} : ()) {
					next if( defined $option -> name() and $option -> name() eq "MSFO");
					next if( defined $option -> name() and $option -> name() eq "FILE");
					next if( defined $option -> name() and $option -> name() eq "PRINT");
					next if( defined $option -> name() and $option -> name() eq "NOABORT");
					if( defined $option -> name() and $option -> name() eq "METHOD") {
						$method = $option -> value();
						$method = "FO" if $option -> value() eq "0";
						$method = "FOCE" if $option -> value() eq "1";
					} else {
						$meth_options = $meth_options." ".$option->name();
						if( defined $option->value() and $option->value() ne "" ) {
							$meth_options = $meth_options."=".$option->value();
						}
					}
				}
				$info{$run}{$method." options"} = $meth_options;
			}
		}

		my @documentation = ();
		foreach my $rec ('sizess','problems','inputs'){
			if (defined $problem->$rec and (defined $problem->$rec->[0]->comment())){
				foreach my $line (@{$problem->$rec->[0]->comment()}){
					chomp $line;
					$line =~ s/\n//g;
					push(@documentation,$line) 
				}
			}
		}

		## Process the documentation comments (this should ideally be a property of the psn-object).
		my $parent;
		my $par_flag = 0;
		my ($inDescription,$inLabel,$inStructural,$inCovariate,$inIIV,$inIOV,$inRSV,$inEstimation) = (0,0,0,0,0,0,0,0);
		for( @documentation) {
			if( $cen_sty ) {
				s/\r\n?/\n/g;
				if( /;;;C\s*[P,p]+arent\s*=\s*(\d+)/ ) {
					$info{$run}{'Based on'} = $1;
					$info{$run}{no_dOFV} = 1 if( $1 == 0 or $1 == "");
					$par_flag = 1;
				}
			} else {
				next unless (/^;;/); #skip lines that do not start with ;;
				if(/Based on:/) {
					$inDescription    = 0;
					$inLabel      = 0;
					$inIOV        = 0;
					$inStructural = 0;
					$inCovariate  = 0;
					$inIIV        = 0;
					$inRSV        = 0;
					$inEstimation = 0;
					s/\r\n?/\n/g;
					s/\s+//g;
					(my $tmp) = (split ":")[1];
					if ($tmp == $run) {
						print "Warning: run $run is said to be based on itself, forbidden. Ignoring tag for run $run.\n";
					}else{
						$info{$run}{'no_dOFV'} = 0;
						if($tmp =~/\[nodOFV\]/) {
							$info{$run}{no_dOFV} = 1;
							$tmp =~ s/\[nodOFV\]//;
						}
						$info{$run}{'Based on'} = $tmp;
					}
					$par_flag = 1;
				}
			}
			if(/Description:/) {
				$inDescription    = 1;
				$inLabel      = 0;
				$inIOV        = 0;
				$inStructural = 0;
				$inCovariate  = 0;
				$inIIV        = 0;
				$inRSV        = 0;
				$inEstimation = 0;
				next;
			}

			## Find the label block
			if (/Label:/) {
				$inDescription= 0;
				$inLabel      = 1;
				$inIOV        = 0;
				$inStructural = 0;
				$inCovariate  = 0;
				$inIIV        = 0;
				$inRSV        = 0;
				$inEstimation = 0;
				next;
			}
			## Find the Structural model block
			if (/Structural model:/) {
				$inDescription    = 0;
				$inLabel      = 0;
				$inIOV        = 0;
				$inStructural = 1;
				$inCovariate  = 0;
				$inIIV        = 0;
				$inRSV        = 0;
				$inEstimation = 0;
				next;
			}

			## Find the Covariate model block
			if (/Covariate model:/) {
				$inDescription    = 0;
				$inLabel      = 0;
				$inIOV        = 0;
				$inStructural = 0;
				$inCovariate  = 1;
				$inIIV        = 0;
				$inRSV        = 0;
				$inEstimation = 0;
				next;
			}

			## Find the IIV model block
			if (/Inter-individual variability:/) {
				$inDescription    = 0;
				$inLabel      = 0;
				$inIOV        = 0;
				$inStructural = 0;
				$inCovariate  = 0;
				$inIIV        = 1;
				$inRSV        = 0;
				$inEstimation = 0;
				next;
			}

			## Find the IOV model block
			if (/Inter-occasion variability:/) {
				$inDescription    = 0;
				$inLabel      = 0;
				$inIOV        = 1;
				$inStructural = 0;
				$inCovariate  = 0;
				$inIIV        = 0;
				$inRSV        = 0;
				$inEstimation = 0;
				next;
			}

			## Find the RSV model block
			if (/Residual variability:/) {
				$inDescription    = 0;
				$inLabel      = 0;
				$inIOV        = 0;
				$inStructural = 0;
				$inCovariate  = 0;
				$inIIV        = 0;
				$inRSV        = 1;
				$inEstimation = 0;
				next;
			}

			## Find the Estimation model block
			if (/Estimation:/) {
				$inDescription    = 0;
				$inLabel      = 0;
				$inIOV        = 0;
				$inStructural = 0;
				$inCovariate  = 0;
				$inIIV        = 0;
				$inRSV        = 0;
				$inEstimation = 1;

				next;
			}

			## Populate the result data structure with the information collected.
			s/\n//;
			if($inDescription) {
				chomp;
				s/;;\s+//;
				$info{$run}{'Description'} = $info{$run}{'Description'}.
				($info{$run}{'Description'} eq "" ? "" : $rsep).$_;
			} elsif ($inLabel) {
				chomp;
				s/;;\s+//;
				$info{$run}{'Label'} = $info{$run}{'Label'}.
				($info{$run}{'Label'} eq "" ? "" : $rsep).$_;
			}elsif ($inStructural) {
				chomp;
				s/;;\s+//;
				$info{$run}{'Structural Model'} = $info{$run}{'Structural Model'}.
				($info{$run}{'Structural Model'} eq "" ? "" : $rsep).$_;
			} elsif ($inCovariate) {
				chomp;
				s/;;\s+//;
				$info{$run}{'Covariate Model'} = $info{$run}{'Covariate Model'}.
				($info{$run}{'Covariate Model'} eq "" ? "" : $rsep).$_;
			} elsif ($inIIV) {
				chomp;
				s/;;\s+//;
				$info{$run}{'IIV'} = $info{$run}{'IIV'}.
				($info{$run}{'IIV'} eq "" ? "" : $rsep).$_;
			} elsif ($inIOV) {
				chomp;
				s/;;\s+//;
				$info{$run}{'IOV'} = $info{$run}{'IOV'}.
				($info{$run}{'IOV'} eq "" ? "" : $rsep).$_;
			} elsif ($inRSV) {
				chomp;
				s/;;\s+//;
				$info{$run}{'RSV'} = $info{$run}{'RSV'}.
				($info{$run}{'RSV'} eq "" ? "" : $rsep).$_;
			} elsif ($inEstimation) {
				chomp;
				s/;;\s+//;
				$info{$run}{'Estimation'} = $info{$run}{'Estimation'}.
				($info{$run}{'Estimation'} eq "" ? "" : $rsep).$_;
			}

		}
		if( not $par_flag ){
			print "Found no parent for model number $run\n";
			$info{$run}{'Based on'} = 0;
		}	

		## Extract information from the output object
		my @outputs = defined $model -> outputs() ? @{$model -> outputs()} : ();
		if( scalar @outputs > 0 and defined $outputs[0] ) {

			my $output = $outputs[0];

			## Loop over each lst file and extract the elapsed estimation
			## and covariance times. This is an ugly hack and should be
			## replaced my an accessor e.g. $output -> est_time();
			my $my_lst = $output -> filename();
			open LST, $my_lst || die "Couldn't open $my_lst\n";
			while(<LST>) {

				## Find the elapsed estimation time inseconds and convert it to minutes
				if(/Elapsed estimation time in seconds:/) {
					chomp;
					s/\s+//;
					$info{$run}{est_time} += sprintf "%6.2f",(split ":")[1]/60;
				}

				## Find the elapsed estimation time inseconds and convert it to minutes
				if(/Elapsed covariance time in seconds:/) {
					chomp;
					s/\s+//;
					$info{$run}{cov_time} = sprintf "%6.2f",(split ":")[1]/60;
				}
			}
			close LST;

			## Extract information from the output object using accessors.
			my @problems = defined $output -> problems() ? @{$output -> problems()} : ();
			if( scalar @problems > 0 and defined $problems[0] ) {
				my $problem = $problems[0];
				$info{$run}{'Nobs'} = $problem -> nobs();
				$info{$run}{'Nind'} = $problem -> nind();

				my @subproblems = defined $problem -> subproblems() ? @{$problem -> subproblems()} : ();
				if( scalar @subproblems > 0 and defined $subproblems[0] ) {
					my $subproblem = $subproblems[0];
					$info{$run}{'OFV'} = $subproblem -> ofv();
					$info{$run}{'Condition Number'} = $subproblem -> condition_number();
					$info{$run}{'Minimization Status'} = $subproblem -> minimization_successful()? "Successful":"Failed";
					$info{$run}{'Covariance Step Status'} = $subproblem -> covariance_step_successful()? "Successful":"Failed";
				}
			}
		}
	}
}

# Calulate the delta OFV, set relations to children, gather parameter names
my %parents = ();
for( my $run = $from; $run <= $to; $run++ ){
	if ( not defined $info{$run}{'Based on'} or
		$info{$run}{'Based on'} eq ""       or 
		$info{$run}{'Based on'} == 0        or 
		$info{$run}{no_dOFV}==1 or
		not defined $info{$info{$run}{'Based on'}}) {

		$parents{$run} = $info{$run};
	} else {
		$info{$info{$run}{'Based on'}}{'children'}{$run} = $info{$run};
		$info{$run}{'dOFV'} = $info{$run}{'OFV'} - $info{$info{$run}{'Based on'}}{'OFV'};
	}
}


my @items = ("Run","Based on","OFV","dOFV","Condition Number","Minimization Status",
	"Covariance Step Status","Label","Description","Structural Model","Covariate Model",
	"IIV","IOV","RSV","Estimation","Datafile","Nobs","Nind","est_time","cov_time",
	"FO options","FOCE options","ITS options","SAEM options","IMP options",
	"BAYES options");

## Print the collected information
open RC,"> $res_file";

## Output some information regarding the generation of the run record info
my $now = localtime;
print RC "The run record information was generated: $now\n";
if($var eq 'no') {
	print RC "Omegas and sigmas are reported as standard deviations.\n";
} else {
	print RC "Omegas and sigmas are reported as variances.\n";
}
if($rse eq 'yes') {
	print RC "Standard errors are reported as relative standard errors (SEs for omegas and sigmas as relative to their variance estimates).\n";
} else {
	print RC "Standard errors are reported as they were reported in the NONMEM output files.\n";
}

print RC "\n";

my $lvl = $max_lvl;
$lvl = 1 if $max_lvl == 0;
if (0){
	my $body = $items[0].$sep x $lvl.join($sep,@items[1..$#items]).
	$sep.join($sep,@{$parameter_names{'theta'}}).
	$sep.join($sep,@{$parameter_names{'omega'}}).
	$sep.join($sep,@{$parameter_names{'sigma'}}).
	$sep.join($sep,@{$parameter_names{'setheta'}}).
	$sep.join($sep,@{$parameter_names{'seomega'}}).
	$sep.join($sep,@{$parameter_names{'sesigma'}})."\n";
}
my $body = $items[0].$sep x $lvl.join($sep,@items[1..$#items]).
$sep.join($sep,@{$parameter_names{'theta'}});
$body = $body.$sep.join($sep,@{$parameter_names{'omega'}}) 
if (scalar(@{$parameter_names{'omega'}}) > 0);
$body = $body.$sep.join($sep,@{$parameter_names{'sigma'}})
if (scalar(@{$parameter_names{'sigma'}}) > 0);
$body = $body.$sep.join($sep,@{$parameter_names{'setheta'}});
$body = $body.$sep.join($sep,@{$parameter_names{'seomega'}})
if (scalar(@{$parameter_names{'seomega'}}) > 0);
$body = $body.$sep.join($sep,@{$parameter_names{'sesigma'}})
if (scalar(@{$parameter_names{'sesigma'}}) > 0);
$body = $body."\n";


sub traverse_runs {
	my $hash_ref = shift;
	my $indentation = shift;
	my $max_lvl = shift;
	$indentation = 0 if $max_lvl == 0;
	my %info = %{$hash_ref};
	my @runs = sort { $a <=> $b } keys %info;
	my $str = "";
	foreach my $run ( @runs ) {
		$str = $str.$sep x $indentation;
		my $itemnum=0;
		foreach my $item (@items) {
			$itemnum++;
			$str = $str.$info{$run}{$item};
			$str = $str.$sep x ($max_lvl-$indentation-1) if($itemnum == 1);
			$str = $str.$sep;
		}
		$itemnum=0;
		foreach my $param ('theta','omega','sigma','setheta','seomega','sesigma') {
			foreach my $name (@{$parameter_names{$param}}) {
				$itemnum++;
				$str = $str.$info{$run}{$param}{$name};
				$str = $str.$sep;
			}
		}
		$str = $str."\n";
		if( defined $info{$run}{'children'} ) {
			$str = $str.traverse_runs($info{$run}{'children'},$indentation+1,$max_lvl);
		}
	}
	$str
}

$body = encode('UTF-8',$body.traverse_runs(\%parents,0,$max_lvl));
my $byte_count = length $body;
print RC $body;

close(RC)
