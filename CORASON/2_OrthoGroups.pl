#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Cwd;

######################################################################
###This is the main script to run the ortho-group tools
######################################################################


my $dir2=&Cwd::cwd();            ##The path of your directory
my $name=pop @{[split m|/|, $dir2]};                       ##Name of the group (Taxa, gender etc)
my $BLAST2="Core$name.blast";


GetOptions(
        'help|?' => \my $help,
        'verbose' => \my $verbose,
        'e_core=f'=>\(my $e_core=.001) ,
        'list=s'=>\my $lista ,
	'num=i'=>\my $num,
        'rast_ids=s' => \my $RAST_IDs2,
	'outname=s'=>\my $outname,
        );

die "$0 requires the argument (-lista\n" unless $lista;
die "$0 requires the argument (-outname\n" unless $outname;  ## Output directory
die "$0 requires the argument (-num\n" unless $num;
die "$0 requires the argument (-outname\n" unless $outname;

#print "This script will help you find a core between genomes or clusters\n";
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

run_blast($outname,$e_core,$lista,$BLAST2);

print "I will run allvsall with blast $outname/$BLAST2\n";


#print "`perl allvsall.pl -R $lista -v 0 -i $BLAST2 -outname $outname`\n";
system(" allvsall.pl -R $lista -v 0 -i $BLAST2 -outname $outname");
#`perl allvsall.pl -R 8,12,57,58,59,60,61,248,261,262,273,275,277,282,310 -v 0 -i ClusterTools1.blast`;

print "Starting Star groups \n num $num\n list $lista\n";
my $corebool=Star($outname,$num,$lista);

if($corebool != 0){
print "SearchAminoacidsFromCore.pl $lista $outname\n";
system("SearchAminoacidsFromCore.pl $lista $outname");


print "ReadReaction $lista $num $outname\n";
system("ReadReaccion.pl $lista $num $outname");
}
else { print "There is no star-core on this clusters\n";}
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
	my $outname=shift;
	my $e=shift;
	my $list=shift;
	my $blastname=shift;
	if (-e "$outname/MINI/Concatenados.faa"){
		#print "File concatenados.faa removed\n";
		unlink ("$outname/MINI/Concatenados.faa");
		}
	system(" header2.pl $list $outname");

	`makeblastdb -in $outname/MINI/Concatenados.faa -dbtype prot -out $outname/MINI/Database.db`;
	`blastp -db $outname/MINI/Database.db -query $outname/MINI/Concatenados.faa -outfmt 6 -evalue $e -num_threads 4 -out $outname/$blastname`;
	
	if (-e "$outname/Core"){
	
		#print "File Core removed\n";
		unlink ("$outname/Core");
		}
	if (-e "$outname/OUTSTAR" ){system ("rm -r $outname/OUTSTAR");}
	system("mkdir $outname/OUTSTAR");
	#print "Se corrió el blast\n";
	#print "\nLista $list#\n";
	#print "Inicia búsqueda de listas de ortologos \n";

}

#_____________________________________________________________________________________
sub Star{
	print "Starting stars\n";
	my $outname=shift;
	my $NUM=shift;
	my $lista=shift;
	my $COLS=$NUM+1;
	my $MIN=$NUM-1;

	  system("cut -f2-$COLS $outname/OUTSTAR/Out.Ortho | sort | uniq -c |  awk '\$1>$MIN' >$outname/Core0");

	my $corebool=0;
	open (CORE0,"<","$outname/Core0") or die "Could not open the file $outname/Core0:$!";
	open (CORE,">","$outname/Core") or die "Could not open the file $outname/Core:$!";

	for my $line (<CORE0>){
		$line=~s/\s*\d*\s*//;
		print CORE $line;
		$corebool=$corebool+1;
		}
	close CORE0;
	close CORE;
#	`rm Core0`;
	return $corebool;

}

#_____________________________________________________________________________________
#`perl depuraANA.pl`;
#`rm lista.$NUM`;
