#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Cwd;

######################################################################
###This is the main script to run the ortho-group tools
######################################################################

my $help;
my $verbose;
my $lista;
my $num;
my $e_core;
my $RAST_IDs2;

my $dir2=&Cwd::cwd();            ##The path of your directory
my $name=pop @{[split m|/|, $dir2]};                       ##Name of the group (Taxa, gender etc)
my $BLAST2="Core$name.blast";


GetOptions(
        'help|?' => \$help,
        'verbose' => \$verbose,
        'e_core=f'=>\($e_core=.001) ,
        'list=s'=>\$lista ,
	'num=i'=>\$num,
        'rast_ids=s' => \$RAST_IDs2,
        );

die "$0 requires the argument (-lista\n" unless $lista;
die "$0 requires the argument (-num\n" unless $num;

#print "This script will help you to find a core between genomes\n";
#print "verbose $verbose\n";
if ($verbose){
print "list$lista\n";
print"number $num\n";
print"e_core $e_core\n";
print "NAME: $name\n";
print "your dir $dir2\n";
print "RAST_IDs $RAST_IDs2\n";}
############################################################
sub listas;
sub run_blast;
sub Star;
######################################################################
########## Main ######################################################

my @LISTA=split(",",$lista);

run_blast($e_core,$lista);

print "I will run allvsall with blast $BLAST2\n";
#print "`perl allvsall.pl -R $list -v 0 -i $BLAST`\n";
system(" allvsall.pl -R $lista -v 0 -i $BLAST2");
#`perl allvsall.pl -R 8,12,57,58,59,60,61,248,261,262,273,275,277,282,310 -v 0 -i ClusterTools1.blast`;

#print "before Star\nnum $num\nlist $lista\n";
Star($num,$lista);

system("SearchAminoacidsFromCore.pl $lista");
system("ReadReaccion.pl $lista $num");

######################################################################
######################################################################
###   Sub  Rutinas (llamadas a los distintos pasos del script
#######################################################################
#######################################################################

sub listas{
	my $NUM=shift;
	my $LIST=shift;
	my $lista="";

	create_list($NUM,$LIST);
	create_listfaa($NUM,$LIST);	
   
	if ($LIST){ 
		#print "Lista de genomas deseados $LIST";
		$lista=$LIST;
		}
	else {
		for( my $COUNT=1;$COUNT <= $NUM ;$COUNT++){
			$lista.=$COUNT;
			if($COUNT<$NUM){
				$lista.=",";
				}
			}
		}
	#print "Se crearon listas del programa\n";
	#print "Se agregó identificador de organismo a cada secuencia\n";

	return $lista;
		
	}

#_____________________________________________________________________________________
sub create_list{  ########### Creates a numbers lists			
	
	my $NUM=shift;
	my $LIST=shift;

	if (-e "lista.$NUM"){
			unlink("lista.$NUM");
			}
	open (LISTA, ">","lista.$NUM");


	if ($LIST){
		my @Genomas=split(",",$LIST);	
		foreach (@Genomas) {
		print LISTA "$_\n";		
			}
		}
	else{	

		my $COUNT=1;
		while  ( $COUNT <= $NUM ){
			print LISTA "$COUNT\n";		
			$COUNT=$COUNT+1;
			}
		}


	close LISTA;
	}

#_____________________________________________________________________________________

sub create_listfaa{
	
	my $NUM=shift;
	my $LIST=shift;

	if (-e "$NUM.lista"){unlink( "$NUM.lista");}
	
	open (LISTA,"<","lista.$NUM") or die "Could not open the file lista.$NUM:$!";
	open (LISTAFAA,">$NUM.lista") or die "Could not open the file $NUM.lista:$!";

	for my $line (<LISTA>){
		chomp $line;
		$line.="\.faa\n";
		print LISTAFAA $line;
		}
	close LISTA;
	close LISTAFAA;
		
	}
#_____________________________________________________________________________________
sub run_blast{
	my $e=shift;
	my $list=shift;
	if (-e "MINI/Concatenados.faa"){
		#print "File concatenados.faa removed\n";
		unlink ("MINI/Concatenados.faa");
		}
	system(" header2.pl $list");

	`makeblastdb -in MINI/Concatenados.faa -dbtype prot -out MINI/Database.db`;
	`blastp -db MINI/Database.db -query MINI/Concatenados.faa -outfmt 6 -evalue $e -num_threads 4 -out $BLAST2`;
	
	if (-e "Core"){
	
		#print "File Core removed\n";
		unlink ("Core");
		}
	if (-e "OUTSTAR" ){system ("rm -r OUTSTAR");}
	system("mkdir OUTSTAR");
	#print "Se corrió el blast\n";
	#print "\nLista $list#\n";
	#print "Inicia búsqueda de listas de ortologos \n";

}

#_____________________________________________________________________________________
sub Star{
	print "Starting stars\n";
	my $NUM=shift;
	my $lista=shift;
	my $COLS=$NUM+1;
	my $MIN=$NUM-1;

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
#`perl depuraANA.pl`;
#`rm lista.$NUM`;
