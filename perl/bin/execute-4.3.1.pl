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

my %required_options = ();
my %optional_options = ( "predict_data:s" => undef,
			 "predict_model:s" => undef,
			 "prepend_options_to_lst!"=> undef,
			 "model_dir_name!" => undef,
			 "tail_output!" => undef,
			 "wintail_exe:s" => undef,
			 "wintail_command:s" => undef,
			 "copy_data!"=>undef
			 );

my $res = GetOptions( \%options,
					  @common_options::get_opt_strings,
					  keys(%optional_options) );

exit unless $res;

common_options::setup( \%options, 'execute' ); #calls set_globals etc, initiates random sequence


my %help_text;

$help_text{Pre_help_message} = <<'EOF';
  <h3 class="heading1">execute</h3>

    Running one or more modelfiles using PsN.

EOF

    $help_text{Description} = <<'EOF';
  <h3 class="heading1">Description:</h3>

    The execute utility is a Perl script that allows you to run multiple
    modelfiles either sequentially or in parallel. It is an nmfe replacement
    with advanced extra functionality.
    <br><br>
    The execute program creates subdirectories where it puts NONMEMs
    input and output files, to make sure that parallel NONMEM runs do not
    interfere with each other. The top directory is by default named
    'modelfit_dirX' where 'X' is a number that starts at 1 and is
    increased by one each time you run the execute utility.
    <br><br>
    When the NONMEM runs are finished, the output and table files will be
    copied to the directory where execute started in which means that you
    can normaly ignore the 'modelfit_dirX' directory. If you need to
    access any special files you can find them inside the
    'modelfit_dirX'. Inside the 'modelfit_dirX' you find a few
    subdirectories named 'NM_runY'. For each model file you
    specified on the command line there will be one 'NM_runY' directory in
    which the actual NONMEM execution takes place. The order of the
    'NM_runY' directories corresponds to the order of the modelfiles given
    on the command line. The first run will take place inside 'NM_run1',
    the second in 'NM_run2' and so on.
EOF

    $help_text{Examples} = <<'EOF';    
  <h3 class="heading1">Example:</h3>

    <p align="justify" class="style2">$ execute pheno.mod </p>

    <p align="justify">Runs one model file and accepts all default values.</p>

    <p align="justify" class="style2">$ execute -threads=2  -retries=5 phenobarbital.mod pheno_alternate.mod</p>

    <p align="justify">Runs two model files in parallel using 5 possible retries.</>p
EOF

    $help_text{Options} = <<'EOF';
  <h3 class="heading1">Options:</h3>

    The options are given here in their long form. Any option may be
    abbreviated to any nonconflicting prefix. The <span class="style2">-threads</span> option may
    be abbreviated to <span class="style2">-t</span> (or even <span class="style2">-thr</span>).
    <br><br>
    The following options are valid:
EOF

$help_text{-predict_data} = <<'EOF';
    <p class="style2">-predict_data='string'</p>
    No help available.
EOF


$help_text{-predict_model} = <<'EOF';
    <p class="style2">-predict_model='string'</p>
    No help available.
EOF

$help_text{-copy_data} = <<'EOF';
    -copy_data
    Set by default. Disable with -no-copy_data. By default PsN will copy
    the data file into NM_run1 and set a local path in psn.mod, the actual
    model file run with NONMEM. If -no-copy_data is set, PsN will not copy 
    the data to NM_run1 but instead set a global path to the data file in
    psn.mod. However, NONMEM will not accept a path longer than 80
	characters.
EOF

$help_text{-model_dir_name} = <<'EOF';
    <p class="style2">-model_dir_name</p>
    Default not used. This option changes the basename of the run directory 
    from modelfit_dir to <modelfile>.dir. where <modelfile> is the name of 
    the first model file in the list given as arguments to execute. The 
    directories will be numbered starting from 1, increasing the number 
    each time execute is run with a model file with the same name. If the 
    option directory is used it will override -model_dir_name.
EOF

    $help_text{-prepend_options_to_lst} = <<'EOF';
    <p class="style2">-prepend_options_to_lst</p>
    This option makes PsN prepend the final lst-file (which is copied 
    back to the directory from which execute was called) with the 
    file version_and_option_info.txt which contains run information, including
    all actual values of optional PsN options. PsN can still parse the  
    lst-file with the options prepended, so the file can still be used it as 
    input to e.g. sumo, vpc or update_inits. Option can be disabled with 
    -no-prepend_options_to_lst if it is set in psn.conf. 
EOF
    $help_text{-tail_output} = <<'EOF';
    <p class="style2">-tail_output</p>
    This option only works for execute under Windows.
    <span class="style2">tail_output</span> specifies that execute
    should invoke a program (tail) that displays the output file,
    including the gradients, during minmization. The tail program is started
    automatically but it is up to the user to terminate the program.

    For the tail_output option to work, a third party
    tail program must be installed. Tail programs that are known to work
    are WinTail and Tail for Win32.  The latter is recommended and can
    be downloaded at http://tailforwin32.sourceforge.net. It
    is also necessary to have correct settings of the variables 
    wintail_exe, which is the path to the tail program, and wintail_command,
    which is the command for the tail program. 
    An example, which works for the Tail for Win32 package, is
    wintail_exe = 'C:\Program Files\Tail-4.2.12\Tail.exe'
    and
    wintail_command = 'tail OUTPUT'
    These two variables must be set in psn.conf, or given on the command-line,
    using the form shown here, including quotation marks.
EOF

$help_text{-wintail_exe} = <<'EOF';
    <p class="style2">-wintail_exe='string'</p>
    Only for Windows. See execute -h tail_output for description.
EOF

$help_text{-wintail_command} = <<'EOF';
    <p class="style2">-wintail_command='string'</p>
    Only for Windows. See execute -h tail_output for description.
EOF

$help_text{Post_help_message} = <<'EOF';
EOF


common_options::online_help('execute', \%options,\%help_text, \%required_options, \%optional_options);


#bad to request user input if wrapper script was used to start PsN. Just make this easy to invoke 
#manually after installing
if ( 0 and $options{'directory'} and (scalar(@ARGV)==1) and (-d $options{'directory'}) and
    (-d $options{'directory'}.'/NM_run1') and (not -d $options{'directory'}.'/NM_run2') and 
    (-e $options{'directory'}.'/NM_run1/stats-runs.csv') and
    (not -e $options{'directory'}.'/NM_run1/psn.lst')) {
  #if single input model and NM_run1 exists and stats-runs exists but not psn.lst,
  #then remove old run directory before starting run.
  print "This looks like a restart of a previously failed run.\n".
      "Do you want to remove the old ".$options{'directory'}." before starting [y/n] ?\n";
  my $input = <STDIN>;
  if( $input =~ /^\s*[yY]\s*$/ ){
    my $dir = $options{'directory'}.'/NM_run1';
    my @files = <$dir/*>;
    foreach my $file (@files){
      unlink ($file);
    }
    rmdir $dir;
    $dir = $options{'directory'};
    my @files = <$dir/*>;
    foreach my $file (@files){
      unlink ($file);
    }
    rmdir $dir;
    print "Removed the old ".$options{'directory'}.".\n"
  }else{
    print "Did not remove the old ".$options{'directory'}.".\n"
  }

}

## Set the automatic renaming of modelfit directory
if ( !$options{'directory'} && $options{'model_dir_name'} ) {
 
    my $dirnamebase = $ARGV[0].".dir";
    my $i = 1;
    while(-e $dirnamebase.".$i") {$i++};
    my $dirname = $dirnamebase.".$i";
    $options{'directory'} = $dirname;
}


my @outputfiles;
my $fake;
if( $options{'outputfile'} ){
  @outputfiles = split( /,/, $options{'outputfile'} );
}

if ( scalar( @ARGV ) < 1 ) {
  unless( $options{'summarize'} and $options{'outputfile'} and not $options{'force'} ){
    print "At least one model file must be specified. Use 'execute -h' for help.\n";
    exit;
  }
  @ARGV = @outputfiles;
  $fake = 1;
}

my $models_array;


my $eval_string = common_options::model_parameters(\%options);
unless (defined $options{'copy_data'} and (not $options{'copy_data'})) {
    $options{'copy_data'} = 1;
}

foreach my $model_name ( @ARGV ){  
	my $outputfile = shift @outputfiles;
	my $model;
	unless( $fake ){
		$model = model -> new ( eval( $eval_string ),
								outputfile                  => $outputfile,
								filename                    => $model_name,
								ignore_missing_output_files => 1 );

		unless ($model->copy_data_setting_ok(copy_data => $options{'copy_data'})){
			die("Cannot set -no-copy_data, absolute data file path is too long.");
		} 
		if (defined $options{'copy_data'} and (not $options{'copy_data'})){
			$model->relative_data_path(0);
		}
		if( $options{'nonparametric_etas'} or
			$options{'nonparametric_marginals'} ) {
			$model -> add_nonparametric_code;
		}
		
		if( $options{'shrinkage'} ) {
			$model -> shrinkage_stats( enabled => 1 );
		}
	} else {
		unless( -e $outputfile ){
			print "The output file: $outputfile doesn't exist.\n";
			exit;
		}
		$model = model -> new( eval( $eval_string ),
							   outputfile => $outputfile,
							   filename   => 'dummy.mod',
							   ignore_missing_files => 1 );
	}

	push( @{$models_array}, $model );

}

if($options{'tail_output'} ) {
	if($Config{osname} ne 'MSWin32'){
		print "Warning: option -tail_output only works on Windows.\n";
		$options{'tail_output'}=0;
	}
	unless (defined $options{'wintail_exe'} ) {
		print "Warning: option -wintail_exe is not set, -tail_output will not work\n";
		$options{'tail_output'}=0;
	}
	unless (defined $options{'wintail_command'} ) {
		print "Warning: option -wintail_command is not set, -tail_output will not work\n";
		$options{'tail_output'}=0;
	}
}

my $modelfit;
if ( defined $options{'predict_data'} and defined $options{'predict_model'} ) {
	if( scalar @{$models_array} > 1 ) {
		die( "When using predict_data and predict_model, no "
			 ."more than one model at a time may be run with execute" );
	}
	my $outfile = $options{'predict_model'};
	$outfile =~ s/\.mod//;
	$outfile = $outfile.'.lst';
	my $pred_mod = $models_array -> [0] -> copy( filename    => $options{'predict_model'},
												 copy_datafile   => 0,
												 copy_output => 0 );
	$pred_mod -> datafiles( new_names => [$options{'predict_data'}] );
	$pred_mod -> ignore_missing_files(1);
	$pred_mod -> outputfile( $outfile );
	$pred_mod -> maxeval( new_values => [[0]] );
	$pred_mod -> remove_records( type => 'covariance' );
	$pred_mod -> update_inits( from_model => $models_array -> [0] );
	my @new_tables;
	foreach my $file ( @{$pred_mod -> table_names -> [0]} ) {
		push( @new_tables, $options{'predict_model'}.'.'.$file );
	}
	$pred_mod -> table_names( new_names => [\@new_tables] );
	$modelfit = tool::modelfit -> 
		new ( eval( $common_options::parameters ),
			  prepend_model_to_lst => $options{'prepend_model_to_lst'},
			  prepend_options_to_lst => $options{'prepend_options_to_lst'},
			  tail_output => $options{'tail_output'},
			  wintail_exe => $options{'wintail_exe'},
			  wintail_command => $options{'wintail_command'},
			  models => [$pred_mod] );  
} else {

	$modelfit = tool::modelfit -> 
		new ( eval( $common_options::parameters ),
			  prepend_model_to_lst => $options{'prepend_model_to_lst'},
			  prepend_options_to_lst => $options{'prepend_options_to_lst'},
			  tail_output => $options{'tail_output'},
			  wintail_exe => $options{'wintail_exe'},
			  wintail_command => $options{'wintail_command'},
			  models => $models_array,
			  copy_data => $options{'copy_data'} );  
}


$modelfit-> print_options (cmd_line => $cmd_line,
						   toolname => 'execute',
						   local_options => [keys %optional_options],
						   common_options => \@common_options::tool_options);


$modelfit -> run;

if( $options{'summarize'} ){
	$modelfit -> summarize;
}
ui -> print( category => 'execute',
			 message => "\nexecute done",
			 newline => 1);
