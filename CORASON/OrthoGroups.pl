#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Cwd;

######################################################################
###This is the main script to run the ortho-group tools
######################################################################

#use globals2;

#print "This script will help you to find a core between genomes\n";
#print "How many genomes would you like to process?\n";
#my $NUM=<>;
#chomp $NUM;


#$infile="CORE";  ##Creará una carpeta asi
#$outdir="$dir"."/"."$infile";
#$DesiredGenes="Core";

############################################################
sub listas;
sub run_blast;
sub Star;
######################################################################
########## Main ######################################################
my $rast_ids;
my $e_core;
my $dir=&Cwd::cwd();            ##The path of your directory
my $name=pop @{[split m|/|, $dir]};             ##The path of your directory
my $blast="$name.blast";
my $lista="";                    ##Wich genomes would you process in case you might, otherwise left empty for whole DB search    
my $num="";                     #the number of genomes to be analized in case you used the option $LIST, comment if $LIST is empty

GetOptions(
        'e_core=f'=>\$e_core ,
        'list=s'=>\$lista ,
        'num=i'=>\$num ,
        'rast_ids=s' => \$rast_ids,
        );




print "NAME: $NAME2\n";
print "your dir $dir2\n";

my $list=listas($NUM2,$LIST2);  #$list stores in a string the genomes that will be used
my @LISTA=split(",",$list);

run_blast($e_core);

print "I will run allvsall with blast $blast\n";
#print "`perl allvsall.pl -R $list -v 0 -i $blast`\n";
`perl allvsall.pl -R $lista -v 0 -i $blast`;
#`perl allvsall.pl -R 8,12,57,58,59,60,61,248,261,262,273,275,277,282,310 -v 0 -i ClusterTools1.blast`;


Star($num,$lista);

`perl SearchAminoacidsFromCore.pl`;
`perl ReadReaccion.pl`;


######################################################################
######################################################################
###   Sub  Rutinas (llamadas a los distintos pasos del script
#######################################################################
#######################################################################
#_____________________________________________________________________________________
sub run_blast{
	if (-e "MINI/Concatenados.faa"){
		print "File concatenados.faa removed\n";
		unlink ("MINI/Concatenados.faa");
		}
	`perl header2.pl`;
	my $e=shift;
	`makeblastdb -in MINI/Concatenados.faa -dbtype prot -out MINI/Database.db`;
	`blastp -db MINI/Database.db -query MINI/Concatenados.faa -outfmt 6 -evalue $e -num_threads 4 -out $BLAST2`;
	
	if (-e "Core"){
	
print "File Core removed\n";
		unlink ("Core");
		}
	if (-e OUTSTAR ){system (rm -r OUTSTAR);}
	system(mkdir OUTSTAR);
	print "Se corrió el blast\n";
	print "\nLista $list#\n";
	print "Inicia búsqueda de listas de ortologos \n";

}

#_____________________________________________________________________________________
sub Star{
	my $NUM=shift;
	my $lista=shift;
	$COLS=$NUM+1;
	$MIN=$NUM-1;

	  system("cut -f2-$COLS ./OUTSTAR/Out.Ortho | sort | uniq -c |  awk '\$1>$MIN' >Core0");


	open (CORE0,"<","Core0") or die "Could not open the file Core0:$!";
	open (CORE,">","Core") or die "Could not open the file Core:$!";

	for my $line (<CORE0>){
		$line=~s/\s*\d*\s*//;
		print CORE $line;
		}
	close CORE0;
	close CORE;
#	`rm Core0`;

}

#_____________________________________________________________________________________
