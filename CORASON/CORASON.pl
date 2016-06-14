#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long 'HelpMessage';
use Cwd;
#print "This script will help you to find a core between genomes\n";
#Author Nelly Selem nselem84@gmail.com
#	After formating database with cor_formatdb this script will get variables and run corason swite
#	B<CORASON.pl> -rast_ids rastIds -q query [-hv] [-s special_org] [-e_value query_evalue] [-c number_of_genes_on_cluster] [-b bit_score] [-e_cluster cluster_e_value] [-e_core core_e_value] [-l genome_selected] [-rescale number]
#print "How many genomes would you like to process?\n";

##################################################################################################
######################################################################################################
########## User variables ############################################################################
######################################################################################################

my $processId=$$;
my $dir=&Cwd::cwd(); 		##The path of your directory
my $name=pop @{[split m|/|, $dir]};                       ##Name of the group (Taxa, gender etc)
my $blast="$name.blast";           		
my $num="";
		##### Window size

my $logo=logo();
####################################################################################################
#########################  end of variables ########################################################
####################################################################################################
################       get options ##############################################################
GetOptions(
	'verbose' => \my $verbose,
        'rast_ids=s' => \my $rast_ids,
	'queryfile=s' => \my $queries,
	'special_org=i' => \(my $special_org=""), 
	'e_value=f'=> \(my $e_value="1E-15"), #sss1E-15  # E value. Minimal for a gene to be considered a hit.
	'bitscore=i'=>\(my $bitscore=0),   ## Revisar el archivo .BLAST.pre para tener idea de este parámetro.
	'cluster_radio=i'=>\(my $cluster_radio="10"),  #number of genes in the neighborhood to be analized
	'e_cluster=f'=>\(my $e_cluster="1E-3"),  #Query search e-value for homologies from reference cluster, values above this will be colore 
	'e_core=f'=>\(my $e_core="1E-3") ,
	'format=i'=>\(my $format_db=1),  #Evalue for the search of ortholog groups within the collection of BGCs 
	'list=s'=>\my $list, ##Wich genomes would you process in case you might, otherwise left empty for whole DB search
	'rescale=i'=>\(my $rescale=85000),  ##### Window size
	'help'     =>   sub { HelpMessage(0) },
       ) or HelpMessage(1);

#######################3 end get options ###############################################3


############################################################################################
#############################################################################################
##############################   Main  ######################################################
print "\n\n ##########################################################\n";
print "Welcome to CORASON \n$logo \n";
print "\n\n ##########################################################\n";
print "Your current directory is $dir, local path $name\n";
printVariables($verbose,$queries,$special_org,$e_value,$bitscore,$cluster_radio,$e_cluster,$e_core,$rescale,$rast_ids);
my $list_all=get_lista($list,$verbose,$rast_ids);
my $number=get_number($list,$list_all,$rast_ids);


#print_module($queries,$special_org,$e_value,$bitscore,$cluster_radio,$e_cluster,$e_core,$rescale,$list_all,$number,$rast_ids,$dir,$name,$blast);
#print "Enter to continue\n";
#my $pause=<STDIN>;

system ("CoreCluster.pl -q $queries  -s $special_org -e_value $e_value -b $bitscore -c $cluster_radio -e_core $e_core -e_cluster $e_cluster -rescale $rescale -l $list_all -num $number -rast_ids $rast_ids");

print "Now I will write the module\n";



###############################################################################################



#################################################################################################################
##########   Subs
####################################################################3

#____________________________________________________________________________________________
sub logo{
my $logo="
-. .-.   .-. .-.   .-. .-.   .-. .-.   .-. .-.   .-. .-.   .   
||\\|||\\ /|||\\|||\\ /|||\\|||\\ /|||\\|||\\ /|||\\|||\\ /|||\\|||\\ /|
|/ \\|||\\|||/ \\|||\\|||/ \\|||\\|||/ \\|||\\|||/ \\|||\\|||/ \\|||\\||
~   `-~ `-`   `-~ `-`   `-~ `-~   `-~ `-`   `-~ `-`   `-~ `-

 	     .-\"    \"-.     .-\"     \"-.
             /          `. .'            \\
            |             \"               \\
            |             Y               |
  _________                               |         
  __  ____/__________________ ____________________
  _  /    _  __ \\_  ___/  __ `/_  ___/  __ \\_  __ \
  / /___  / /_/ /  /   / /_/ /_(__  )/ /_/ /  / / /
  \\____/  \\____//_/    \\__,_/ /____/ \\____//_/ /_/   
             \\       	               /' 
              `\\                     /'
                `\\                 /'
                  `\\             /'
                    `\\         /'
                      `\\     /'
                        `\\ /'
                          Y
 ";
return $logo;
}

#______________________________________________________________________

sub get_number{
	my $list=shift;
	my $list_all=shift;
	my $rast_ids=shift;
	my $NUM;
	#if ($verbose){print "list #$list# total list: $list_all\n";}

	if ($list eq ""){
		$NUM = `wc -l < $rast_ids`;
		chomp $NUM;
		$NUM=int($NUM);
		if ($verbose ){print "Every genome on data base would explored\n"; }
		}
	else {
		if($list_all =~ /not/){
			print "Your genome list must be numbers separated by , \n you can select intervals using ':'\n Example: 2,3,4:7,9 means 2,3,4,5,6,7,9";
			print"$list_all\n";
			exit;
			}
		else{
			if ($verbose){print "You will explore genomes $list_all\n";}
			my @st=split(",",$list_all);
			$NUM=scalar @st;			
			}
		}
		print "You will explore $NUM genomes\n";
		return $NUM;
	}

#________________________________________________________________________

sub get_lista{
	my $list=shift;
	my $verbose=shift;
	my $rast_ids=shift;
	my $result;
	my $bool=1;
	my @all;

	if (!$list){ 
		print "All genomes would be procesed\n";
		if (-e $rast_ids){
			@all=`cut -f1 $rast_ids`;
			for my $genome (@all){chomp $genome;}
			@all = grep { $_ ne "" } @all;
			$result=join(',',@all);
			if($verbose) { for my $genome (@all){print  "#$genome#\t";}}
			}
		else { 
			print "$rast_ids file is needed\n$!";
			exit;
			}
		}
	else{
		my @split_list= split(",",$list);
		#if ($verbose){print "your list is $list\n";}
		foreach my $st (@split_list){
			#if($verbose){print "With elements: #$st#\n";}
			if($st=~/\:/){  ## If st is a range of numbers
				#if ($verbose){print "Range $st on list\n";}				
				my @range=split(/\:/,$st);
				my $init=$range[0];
				my $end=$range[1];
				my $bool_init=0;
				my $bool_end=0;
	
				if($init=~/^\d+\z$/) {$bool_init=1;}			
				if($end=~/^\d+\z$/) {$bool_end=1;}			
			
				if ($init > $end){
					print "ERROR: You selected interval $init:$end, at an interval, you must be sure that initial number is lower than end number\n";
					exit;			
					}

				if($bool_init==1 and $bool_end==1 ){
					for (my $element=$init;$element<=$end;$element++){
						push(@all,$element);
	#					if ($verbose){print "Adding element $element to list\n";}
					
						}
					}
				else{
					$bool=$bool_init*$bool_end;
					}
				}
			else{ 
				## if st is a number
				my $bool_st=0;
				if($st=~/^\d+\z$/) {$bool_st=1;}			
				if ($bool_st==1){
					push(@all,$st);
		#			if ($verbose){print "Adding element $st to list\n";}
					}
				else{$bool=$bool*$bool_st;}		
				}
			}
		if($bool==1){
	    		my @sorted_numbers = sort { $a <=> $b } @all;
			    my @unique = do { my %seen; grep { !$seen{$_}++ } @sorted_numbers };	
			$result=join(',',@unique)}
			else{$result="This is not a list number acepted format, please use only , and : to separate numbers\n";}

		#if ($verbose) {print "Whole list #$result#\n";}
	}
	return $result;
	}

#_____________________________________________________________________________________________

sub printVariables {
	my $verbose=shift; 
	my $queries=shift;
	my $special_org=shift;
	my $e_value=shift;      
	my $bitscore=shift; 	
	my $cluster_radio=shift; 
	my $e_cluster=shift;
	my $e_core=shift;
	my $rescale=shift; 
	my $rast_ids=shift;

#######################################################################################
## Default values
	my $e_value_default="1E-15";
	my $bitscore_default=0;
	my $cluster_radio_default="15";
	my $e_cluster_default="1E-3";   		#Query search e-value for homologies from reference cluster, values above this will be colored
	my $e_core_default="1E-3";
	my $list_default=""; 			##Wich genomes would you process in case you might, otherwise left empty for whole DB search    
	my $rescale_default="8500"; 			##### Window size
	my $rast_ids_default="RAST.IDs"; 			##### Window size
##########################################################################################
	print "\n\n";

	if ($verbose){print "You are on verbose mode\n";}

	if ($queries){ $queries=print "I must check $queries is a fasta file\n";} 
	else {print "A query file is needed, please provide one!\n"; exit;}
	
	if ($special_org){ print "Your cluster is located on organism number $special_org\n";} 
	else {print "No reference organism has been provided, best hit would be used as a reference cluster\n";}
	

	if ($e_value!=$e_value_default){
		if ($e_value<0){ print "An e-value at least cero must be given\n"; exit;} 
		else {print "e-value for your query is $e_value\n";}
			}
	else {print "Default e-value=$e_value\n"}


	if ($bitscore==$bitscore_default){ print "Your bitscore is set to $bitscore, you can use a positive bitscore to reduce your hunchs\n"; } 	
	elsif ($bitscore <0){print "bitscore must be greater or equal than cero"; exit;}
	elsif ($bitscore >0){print "bitscore is $bitscore\n";}
	

	
	if ($cluster_radio != $cluster_radio_default){
		if ($cluster_radio < 0){
			print "You must chose how many genes around your query would you like to explore\nChose a positive number";
			}
		else{print "the radio of your cluster is $cluster_radio\n";}
		}
	else {print "the radio of your cluster is the default value: $cluster_radio\n";}





	if ($e_cluster!=$e_cluster_default){
		if ($e_cluster<0){print "Cluster homology minimus e-value must be at least 0\n";}
		if ($e_cluster>=0){
			print "Minimal e-value to be consider an homologous of a cluster member is: $e_cluster\n";
			}
		}
	else {
		print "Minimal e-value to be consider an homologous of a cluster member is:  $e_cluster\n";}


	if ($e_core!=$e_core_default){
		if ($e_core<0){
			print "Cluster homology minimus e-value must be at least 0\n";
			}
		if ($e_core>=0){
			print "Minimal e-value for ortho groups in core: $e_core\n";
			}
		}
	else {
		print "Minimal e-value for ortho groups in core $e_core \n";
		}




	if ($rescale!=$rescale_default){
		if ($rescale<0){
			print "Gene size rescale must be at least 0\n";
			}
		if ($rescale>=0){
			print "You are rescaling gene size by a factor: $rescale\n";
			}
		}
	else {
		print "You are rescaling gene size by a factor: $rescale \n";
		}

	if (-e $rast_ids){
		print "Your rast ids file is $rast_ids";
		}
	else{
		print "Can't find $rast_ids\n Rast ids file is needed,please provide one\n";
		exit;
		}
	}
#_____________________________________________________________________________________
#sub print_module{
#	my ($queries,$special_org,$e_value,$bitscore,$cluster_radio,$e_cluster,$e_core,,$rescale,$lista,$num,$RAST_IDs,$dir,$name,$blast)=@_;
	#print "Queries $queries\n";
#	my $path="/opt/CORASON";
#	`cp $path\/globalsFormat.pm $path\/Globals.pm`;
#	print "File copied\n";
#	print "Enter to Continue\n";
#	my $pause=<STDIN>;

 #	system("perl -p -i -e '/SPECIAL_ORG/ && s/\"\"/\"$special_org\"/' $path\/Globals.pm");	
#	system("perl -p -i -e '/QUERIES/ && s/\"\"/\"$queries\"/' $path\/Globals.pm");	
#	system("perl -p -i -e '/e_VALUE/ && s/\"\"/\"$e_value\"/' $path\/Globals.pm");	
#	system("perl -p -i -e '/BITSCORE/ && s/\"\"/\"$bitscore\"/' $path\/Globals.pm");	
#	system("perl -p -i -e '/CLUSTER_RADIO/ && s/\"\"/\"$cluster_radio\"/' $path\/Globals.pm");	
#	system("perl -p -i -e '/e_CLUSTER/ && s/\"\"/\"$e_cluster\"/' $path\/Globals.pm");	
#	system("perl -p -i -e '/e_CORE/ && s/\"\"/\"$e_core\"/' $path\/Globals.pm");	
#	system("perl -p -i -e '/RAST_IDs/ && s/\"\"/\"$RAST_IDs\"/' $path\/Globals.pm");	
#	system("perl -p -i -e '/NAME/ && s/\"\"/\"$name\"/' $path\/Globals.pm");	
#	system("perl -p -i -e '/BLAST/ && s/\"\"/\"$blast\"/' $path\/Globals.pm");	
#	system("perl -p -i -e '/DIR/ && s/\"\"/\"$dir\"/' $path\/Globals.pm");	
#	system("perl -p -i -e '/LIST/ && s/\"\"/\"$lista\"/' $path\/Globals.pm");	
#	system("perl -p -i -e '/NUM/ && s/\"\"/\"$num\"/' $path\/Globals.pm");	
#	system("perl -p -i -e '/RESCALE/ && s/\"\"/\"$rescale\"/' $path\/Globals.pm");	
	
#	print "one liner executd\n";
#}
