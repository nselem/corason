#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long 'HelpMessage';
use Cwd;

use Term::ANSIColor;


######################################################################
###This is the main script to run the ortho-group tools
######################################################################

# This script will help you to find a core between Clusters and sort them accordingly
# Author Nelly Selem nselem84@gmail.com 2016
#	
#	$ corason.pl -rast_ids rastIds -q query -s special_org [-hv] [-e_value query_evalue] [-c number_of_genes_on_cluster] [-b bit_score] [-e_cluster cluster_e_value] [-e_core core_e_value] [-l genome_selected] [-rescale number]

=head1 NAME

Corason - pass your inputs trough the command line!

=head1 SYNOPSIS

CORASON extense manual can be consulted at: https://github.com/nselem/EvoDivMet/wiki/Detailed-Tutorial/

  --rast_ids  		Required when faa files are used (No Default) RAST ids tab-separated table with the following Rast data.
			 Job id\tGenome id\tOrganism name.

  --g                   Genbank mode. If CORASON is used with genbank files instead of RAST fasta files, then -g must be used. 
			A RAST ids file will be automatically created in this mode.

  --queryfile,-q	Required (No default)   Your aminoacid sequence on fasta file.

  --special_org,-s    	Required (No default)   Job Id (from RAST) for the cluster where your query belongs. 

  --e_value           	Default: 1E-15 (float)  E value. Minimal for a gene to be considered a hit.

  --bitscore,-b       	Default: 0 (Positive integer) After one run look into file .BLAST.pre to be more restrictive on hits.

  --cluster_radio -c  	Default: 10 (Positive integer) Number of genes in the neighborhood to analize.

  --e_cluster 	      	Default: 1E-3 (float)  e-value for sequences from reference cluster, values above it will be colored. 

  --e_core 	      	Default: 1E-3 (float) e-value for Best Bidirectional Hits used to cunstruct genomic core from clusters.

  --list 	      	Default: GENOME/*.faa (string separated by "," or ":". 
			Example 1,2,4:6 produce a search on genomes 1,2,4,5,6)
			Leaving this option empty will conduce to search on all genomes in GENOME directory.

  --rescale,r         	Default: 85000 (integer) Increasing this number will show a bigger cluster region with smaller genes.

  --antismash,a      	AntiSMASH file optional 
 
  --verbose,v           If you would like to read more output from dir_scripts. 
			Most of the time only useful if you would like script debugging.

Remarks:
For float values (as e_value, e_core etc) 0.001 will work, but .001 won't do it.


=head1 VERSION

0.01

=cut

##################################################################
########## Local variables ############################################################################

my $processId=$$;
my $dir=&Cwd::cwd(); 		##The path of your directory
my $name=pop @{[split m|/|, $dir]};                       ##Name of the group (Taxa, gender etc)
my $blast="$name.blast";           		
my $num="";
		##### Window size

####################################################################################################
#########################  end of variables ########################################################
################       get options ##############################################################
GetOptions(
	'verbose' => \my $verbose,
        'gbk' => \my $gbk,
        'conda' => \my $conda,
        'rast_ids=s' => \my $rast,
	'queryfile=s' => \my $queries,
	'special_org=s' => \(my $special=""), 
	'e_value=f'=> \(my $e_value="1E-15"), 
	'bitscore=i'=>\(my $bitscore=0),   
	'cluster_radio=i'=>\(my $cluster_radio="10"),  
	'e_cluster=f'=>\(my $e_cluster="1E-3"),   
	'e_core=f'=>\(my $e_core="1E-3") ,
	'format=i'=>\(my $format_db=1),   
	'list=s'=>\(my $list=""), 
	'rescale=i'=>\(my $rescale=85000),
	'antismash=s'=> \(my $antismash="none"),
	'help'     =>   sub { HelpMessage(0) },
       ) or HelpMessage(1);

#######################3 end get options ###############################################3
print color('bold blue');
print "\n$0 requires the queries argument (--q\n\n" and print color('reset') and print "for help, type:\ncorason.pl -h\n\nConsult our wiki:https://github.com/nselem/EvoDivMet/wiki\n\n" and HelpMessage(1) unless $queries;  ## A genome list is mandator

	print "\n$0 requires the special_org argument (--s\n\n" and print color('reset') and print "for help, type:\ncorason.pl -h\n\nConsult our wiki at:https://github.com/nselem/EvoDivMet/wiki\n\n" and HelpMessage(1) unless $special;  ## A genome list is mandatory

my $dir_scripts="/opt/corason/CORASON";
if($conda){print"Conda mode"; $dir_scripts="CORASON";}
#print("gbk $gbk $rast $special");exit;

my ($special_org,$rast_ids)=modes($special,$rast,$gbk,$dir_scripts);
#HelpMessage(1) unless ($queries and $rast_ids and $special_org);
############################################################################################
#############################################################################################
##############################   Main  ######################################################
print "\n\n ##########################################################\n";

my $logo=logo();
print color('bold black');
print "Welcome to CORASON \n";
print color('reset');
print color('bold red');
print "$logo \n";
print color('reset');
print "\n\n ##########################################################\n";
print "Your current directory is $dir, local path $name\n";


printVariables($verbose,$queries,$special_org,$e_value,$bitscore,$cluster_radio,$e_cluster,$e_core,$rescale,$rast_ids,$antismash);
my $list_all=get_lista($list,$verbose,$rast_ids);

my $number=get_number($list,$list_all,$rast_ids);


## Modifying to conda version
if($conda){
print ("$dir_scripts/CoreCluster.pl -q $queries  -s $special_org -e_value $e_value -b $bitscore -cluster_radio $cluster_radio -e_core $e_core -e_cluster $e_cluster -rescale $rescale -l $list_all -num $number -rast_ids $rast_ids -antismash $antismash -conda $conda");
system ("$dir_scripts/CoreCluster.pl -q $queries  -s $special_org -e_value $e_value -b $bitscore -cluster_radio $cluster_radio -e_core $e_core -e_cluster $e_cluster -rescale $rescale -l $list_all -num $number -rast_ids $rast_ids -antismash $antismash -conda $conda");
}
else{
print ("$dir_scripts/CoreCluster.pl -q $queries  -s $special_org -e_value $e_value -b $bitscore -cluster_radio $cluster_radio -e_core $e_core -e_cluster $e_cluster -rescale $rescale -l $list_all -num $number -rast_ids $rast_ids -antismash $antismash ");
system ("$dir_scripts/CoreCluster.pl -q $queries  -s $special_org -e_value $e_value -b $bitscore -cluster_radio $cluster_radio -e_core $e_core -e_cluster $e_cluster -rescale $rescale -l $list_all -num $number -rast_ids $rast_ids -antismash $antismash ");
}
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
\n\nCORASON-BGC\n
CORe Analysis of Syntenic Orthologs Natural Product-Biosynthetic Gene Cluster\n\n

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

	if ($list eq ""){ 
		print "\nAll genomes would be procesed\n";
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
        my $antismash=shift;
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
	if ($antismash){print "You will use antiSMASH file $antismash  \n";}

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
#----------------------------------------------------------------
sub modes{
## This sub load initial special_org number and RAST_ids values according to 
#the user input gbks or RAST fasta
### GBK to fasta inputs

	print " Picking mode gbk/RAST \n"; 
	my $special=shift;
	my $rast=shift;
	my $gbk=shift;
	my $dir_scripts=shift;
	my $special_new;
	my $rast_ids=$rast;
	if($gbk ){
			print("$dir_scripts/gbkIndex.pl CORASON_GENOMES $dir_scripts");
			system("$dir_scripts/gbkIndex.pl CORASON_GENOMES $dir_scripts");
			$rast_ids="Corason_Rast.IDs";
			$special_new=`grep -w $special Corason_Rast.IDs|cut -f1`;
			chomp $special_new;
#			print "special $special_new";
#			exit;
	}
	else{
		print "\n$0 requires the rast_ids argument (--rast_ids\n\n" and print color('reset') and print "for help, type:\ncorason.pl -h\n\nConsult our wiki:https://github.com/nselem/EvoDivMet/wiki\n\n" and HelpMessage(1) unless $rast;  ## A genome list is mandatory

	print "special org: $special\n";
	if ($special=~m/\.faa/){
	$special=~s/\.faa//;	
		}
	$special_new=$special;	
#	print "special org: $special\n";
	}
	print "rast=$rast_ids\tspecial=$special_new\n";
	#exit;
	return ($special_new,$rast_ids)	
}

