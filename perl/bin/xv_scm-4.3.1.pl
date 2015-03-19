#!perl.exe
use FindBin qw($Bin);
use lib "$Bin/../site/lib/PsN_4_3_1";
# the above was entered by psnGlobalToLocalPaths

use PsN;
use file;
use model;
#use tool;
use tool::xv_step;
use tool::scm;
use tool::scm::config_file;
use tool::modelfit;
use Math::Random;
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

#remove options search_direction gof p_value p_forward p_backward
#update_derivatives

my %optional_options = ( "groups:i" => '',
			 "splits:i" => '',
			 "stratify_on:s" => '',
			 "global_init:s" => '',
			 "logfile:s" => '',
			 "model:s" => '',
			 "noabort!" => '',
			 "max_steps:i" => '',
			 "do_not_drop:s" => '',
			 "linearize!" => '',
			 "epsilon!" => '',
			 "foce!" => '',
			 "lst_file:s" => '',
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

#below this line comes my %help_text;
##move this up again
my %help_text;
$help_text{Pre_help_message} = <<'EOF';

    Stepwise covariate model building from NONMEM models.
        
EOF

$help_text{Description} = <<'EOF';

    The Cross-validated Stepwise Covariate Model (XV_SCM) building tool 
    of PsN implements cross-validated model size selection for a
    covariate model. It relies on the SCM tool of PsN.
        
    A configuration file must be written for each xv_scm run. The 
    format of the configuration file follows the format of the scm
    configuration file exactly, except that options 
    search_direction, gof, p_value, p_forward, p_backward and 
    update_derivatives are ignored.
    
EOF

$help_text{Examples} = <<'EOF';

    Execute an XV_SCM using parameters set in the config file
    'phenobarbital.scm'.

    xv_scm -config_file=phenobarbital.scm

    Execute an XV_SCM using parameters set in the config file
    'phenobarbital.scm'. But override the retries and the seed
    parameter.


    xv_scm -config_file=phenobarbital.scm -retries=5 -seed=12345 phenobarbital.mod

EOF
		
$help_text{Options} = <<'EOF';

    The options are given here in their long form. Any option may be
    abbreviated to any nonconflicting prefix. The -threads option may
    be abbreviated to <span class="style2">-thr</span>.

    The following options are valid:

EOF

    $help_text{-h} = <<'EOF';
    <p class="style2">-h | -?</p>

    With -h or -? xv_scm will print a list of options and exit.
EOF

    $help_text{-help} = <<'EOF';
    <p class="style2">-help</p>

    With -help xv_scm will print this, longer, help message.
EOF

    $help_text{-config_file} = <<'EOF';
    <p class="style2">-config_file</p>

    File name of an scm configuration file.
EOF

    $help_text{-global_init} = << 'EOF';
    <p class="style2">-global_init</p>

    Use scm -help global_init for information on this option.
EOF
    $help_text{-noabort} = <<'EOF';
    <p class="style2">-noabort</p>

    Use scm -help noabort for information on this option.
EOF

    $help_text{-logfile} = << 'EOF';
    <p class="style2">-logfile</p>

EOF

$help_text{-groups} = <<'EOF';
      -groups=N

    Default 5. The number of validation groups to make an N-fold cross-validation.  
EOF
$help_text{-splits} = <<'EOF';
      -splits=N

    Default 1. The number times to perform a complete cross-validation
    with a new data split. 
EOF
$help_text{-max_steps} = <<'EOF';
      -max_steps=N

    Do not take more that max_steps forward steps,
    even if there are more covariates left to add and a significant
    inclusion was made in the last step.
EOF

    $help_text{-model} = << 'EOF';
    <p class="style2">-model</p>

    The name of the basic model file, without any parameter-covariate
    relations included.
EOF

$help_text{-stratify_on} = <<'EOF';
      -stratify_on=variable

    PsN will try to preserve the relative proportions of individuals
    with different values of the stratification variable
    when creating data subsets during cross-validation.
    The stratification variable must be found in the original dataset,
    and there must be at least 'groups' individuals having each
    unique value of the stratification variable. If the stratification
    variable is continuous it is recommended to first group the values
    and then stratify on group number instead of the continuous variable.
EOF

    $help_text{-do_not_drop} = << 'EOF';
    <p class="style2">-do_not_drop</p>

    Use scm -help do_not_drop for information on this option.
EOF

    $help_text{-linearize} = <<'EOF';
    <p class="style2">-linearize</p>

    Use scm -help linearize for information on this option.
EOF
    $help_text{-foce} = <<'EOF';
    <p class="style2">-foce</p>

    Use scm -help foce for information on this option.
EOF
    $help_text{-derivatives_data} = <<'EOF';
    <p class="style2">-derivatives_data</p>

    Use scm -help derivatives_data for information on this option.
EOF

    $help_text{-epsilon} = <<'EOF';
    <p class="style2">-epsilon</p>

    Use scm -help epsilon for information on this option.
EOF
    $help_text{-lst_file} = <<'EOF';
    <p class="style2">-lst_file</p>

    Use scm -help lst_file for information on this option.
EOF
    $help_text{-only_successful} = <<'EOF';
    <p class="style2">-only_successful</p>

    Use scm -help only_successful for information on this option.
EOF
    $help_text{-parallel_states} = <<'EOF';
    <p class="style2">-parallel_states</p>

    Use scm -help parallel_states for information on this option.
EOF

    $help_text{Post_help_message} = <<'EOF';
    Also see 'scm -h' for a list of scm options,
    and 'psn_options -h' for a description of common options.
EOF


common_options::online_help( 'xv_scm', \%options, \%help_text, \%required_options, \%optional_options);


if ( $options{'config_file'} eq '' ){
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
common_options::setup( \%options, 'xv_scm' ); 

$config_file->gof('p_value');
$config_file->p_value(1);
$config_file->search_direction('forward');
$config_file->update_derivatives(0);
$config_file->{'ofv_change'} = undef if defined ($config_file -> ofv_change()); #FIXME for Moose

my $original_included=undef;
if( defined $config_file -> included_relations() ){
  $original_included=$config_file -> included_relations();
}


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


my $eval_string = common_options::model_parameters(\%options);
my $model = model -> new ( eval $eval_string,
			   filename           => $config_file -> model) ;
$model->set_option( record_name => 'estimation',
		      option_name => 'FORMAT',
		      fuzzy_match => 1,
		      option_value => 's1PE17.10');

if( $options{'shrinkage'} ) {
  $model -> shrinkage_stats( enabled => 1 );
}

if (defined $options{'stratify_on'}){
  my $column_number;
  my ( $values_ref, $positions_ref ) = $model ->
      _get_option_val_pos ( problem_numbers => [1], 
			    name        => $options{'stratify_on'},
			    record_name => 'input',
			    global_position => 1  );
  $column_number = $positions_ref -> [0];
  die "Cannot find ".$options{'stratify_on'}." in \$INPUT"
      unless ( defined $column_number );
  $options{'stratify_on'} = $column_number;
}

my $return_dir = getcwd();
my $main_directory = $options{'directory'};
if (defined $main_directory){
  $main_directory =$return_dir.'/'.$main_directory.'/';
}else{
  $main_directory= OSspecific::unique_path( 'xv_scm_dir' ,$return_dir);
}
mkdir( $main_directory) unless ( -d  $main_directory);
#copy config file to rundir
my ( $dir, $file ) = OSspecific::absolute_path('',$options{'config_file'});
cp($dir.$file,$main_directory.$file);

$options{'splits'}=1 unless (defined $options{'splits'});
$options{'groups'}=5 unless (defined $options{'groups'});

my @seeds;
my @results;
for (my $split=1; $split<= $options{'splits'}; $split++){
  push(@seeds,random_uniform_integer( 1,0,1000000 ));
}

my %xv_results;
my $maxlev=0;


#must compute covariate statistics for complete dataset
#outside of splits, and use global max and min for computing
#bounds of covariate thetas. Filter on IGNORE we do not do yet.
#have missing data must also be global
#need to know the covariates here.

chdir($main_directory);
my $global_scm;
my $temp_scm_dir='full_data_statictics';

$global_scm = tool::scm -> 
    new ( eval( $common_options::parameters ),
	  models	=> [$model],
	  config_file => $config_file,
	  directory => $temp_scm_dir,
	  both_directions => 0,
	  seed => '1234');

my $global_covariate_statistics = $global_scm -> covariate_statistics;
$global_scm = undef;

## done stats


for (my $split=1; $split<= $options{'splits'}; $split++){
  chdir($main_directory);
  my $run_directory = $main_directory.'split_'.$split;
  mkdir( $run_directory) unless ( -d  $run_directory);
  chdir($run_directory);

  #copy lasso creation of xv_data
  #create xv data, use relative path to this directory when running nonmem

  my $data_xv = tool::xv_step -> new( 
    %{common_options::restore_options(@common_options::tool_options)},
    models => [$model],
    nr_validation_groups => $options{'groups'},
    stratify_on      => $options{'stratify_on'},
    base_directory => $run_directory,
    directory => $run_directory.'/xv_data',
    seed => $seeds[$split-1]);

  if ($split == 1){
    $data_xv->print_options(cmd_line => $cmd_line,
		      toolname => 'xv_scm',
		      local_options => [keys %optional_options],
		      common_options => \@common_options::tool_options,
                      directory => $main_directory);
  }
  $data_xv -> create_data_sets();

  for (my $group=1; $group<= $options{'groups'}; $group++){
    #change data in model to training $step
    my $model_group = 
	$model -> copy(filename => $run_directory.'/model_group'.$group.'.mod',
		       copy_datafile => 0,
               output_same_directory => 1,
               copy_output => 0,
               write_copy => 0);

    
    $model_group -> datafiles( new_names => [$data_xv->estimation_data() -> [$group-1]] );

    ui -> print( category => 'xv_scm',
		       message => "Starting scm forward search for xv_scm ".
		       "split $split group $group",
                       newline =>1);
    ui->category('scm');
    $model_group -> _write;



    my $scm;
    if (defined $original_included){
        $config_file -> included_relations($original_included);
    }
#change xv_pred_data to filenames
    $scm = tool::scm -> 
	new ( eval( $common_options::parameters ),
	      models	=> [$model_group],
	      config_file => $config_file,
	      directory => 'scm_xv_group'.$group,
	      both_directions => 0,
	      global_covariate_statistics => $global_covariate_statistics,
	      xv_pred_data => $data_xv->prediction_data() -> [$group-1],
	      seed => $seeds[$split-1]);
            
    $scm -> run;
    ui->category('xv_scm');
    foreach my $lev (sort keys %{$scm -> xv_results()}){
      $xv_results{'ofv'}{$split}{$group}{$lev}=$scm -> xv_results->{$lev}{'ofv'};
      my $rel = $scm -> xv_results->{$lev}{'relation'};
      unless ($rel eq 'base'){
	#store both rank and count here, separate
	$xv_results{$rel}{'rank'}{$split}{$group}=$lev;
	if (defined $xv_results{$rel}{'count'}){
	  if (defined $xv_results{$rel}{'count'}{$lev}){
	    $xv_results{$rel}{'count'}{$lev} = $xv_results{$rel}{'count'}{$lev}+1;
	  }else{
	    $xv_results{$rel}{'count'}{$lev} = 1;
	  }
	}else{
	  $xv_results{$rel}{'count'}{$lev} = 1;
	}
      }
    }
    $maxlev = scalar(keys %{$scm -> xv_results()}) 
          if (scalar(keys %{$scm -> xv_results()}) > $maxlev);
  }
}

chdir($main_directory);

#1)sum up pred ofvs, create csv with individual pred-ofv (one per split),
#mean pred-ofv
open( XV, ">> xv_ofv_results.csv" );
print XV ",Prediction ofv";
for (my $split=1; $split<= $options{'splits'}; $split++){
    for (my $group=1; $group<= $options{'groups'}; $group++){
       print XV ",";
    }
}
print XV "\n";
print XV "Level,Mean over splits";
for (my $split=1; $split<= $options{'splits'}; $split++){
  print XV ",split $split total";
  for (my $group=1; $group<= $options{'groups'}; $group++){
    print XV ",split $split group $group";
  }
}
print XV "\n";

for (my $lev=0;$lev< $maxlev; $lev++){
  my $totstr;
  my $totsum=0;
  for (my $split=1; $split<= $options{'splits'}; $split++){
    my $sum = 0;
    my $str;
    for (my $group=1; $group<= $options{'groups'}; $group++){
      $str .= ",".$xv_results{'ofv'}{$split}{$group}{$lev};
      $sum += $xv_results{'ofv'}{$split}{$group}{$lev} 
         if (defined $xv_results{'ofv'}{$split}{$group}{$lev});
    }
    $totsum += $sum;
    $totstr .= ','.$sum."$str";
  }
  print XV $lev.','.$totsum/$options{'splits'}."$totstr\n";
}
close XV;


#2)rank order for covariates in each scm
open( XV, ">> xv_relation_rank_order.csv" );
print XV "Relation";
for (my $split=1; $split<= $options{'splits'}; $split++){
  for (my $group=1; $group<= $options{'groups'}; $group++){
    print XV ",split $split group $group";
  }
}
print XV "\n";

for my $rel (keys %xv_results){
  next if ($rel eq 'ofv');
  print XV "$rel";
  for (my $split=1; $split<= $options{'splits'}; $split++){
    for (my $group=1; $group<= $options{'groups'}; $group++){
      print XV ",".$xv_results{$rel}{'rank'}{$split}{$group};
    }
  }
  print XV "\n";
}
close XV;





#3) at each lev XX included YY% of the time
open( XV, ">> xv_percent_inclusion_by_level.csv" );
print XV "Relation";
for (my $lev=1;$lev<$maxlev; $lev++){
  print XV ",$lev";
}
print XV "\n";
my $maxN = $options{'splits'}*$options{'groups'};
for my $rel (keys %xv_results){
  next if ($rel eq 'ofv');
  print XV "$rel";
  my $sum = 0;
  for (my $lev=1;$lev< $maxlev; $lev++){
    $sum += $xv_results{$rel}{'count'}{$lev};
    print XV ",".(100*$sum/$maxN);
  }
  print XV "\n";
}
close XV;

chdir($return_dir);

ui -> print( category => 'xv_scm',
	     message => "\nxv_scm done",
             newline => 1);
