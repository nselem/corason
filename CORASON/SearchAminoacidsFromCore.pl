#!/usr/bin/perl
use strict;
use warnings;
use Cwd;

#####################################
#REQUERIMIENTOS:
#-LISTA DE GENOMAS
#####################################

my $dir2=&Cwd::cwd(); 
my $name=pop @{[split m|/|, $dir2]};                       ##Name of the group (Taxa, gender etc)
my $infile=$name;
my $list=$ARGV[0];
my $outname=$ARGV[1];
my $outdir="$dir2/$outname/$infile";
my $DesiredGenes="Core";

#-----------------------------------------

#print "Seleccionando unicos...\n";
if (-e "$outname/$outdir"){
	system "rm -r $outdir/FASTAINTER/";
	system "rm -r $outdir/FASTAINTERporORG/";
	system "rm lista.ORTHOall";
	system "rm -r $outdir";
	}

system "mkdir $outdir";
system "mkdir $outdir/FASTAINTERporORG/";
system "mkdir $outdir/FASTAINTER/";



## Imprimir 
#print "$dir/FASTA";
#readMINI($dir2,$listaname);

### Leer todos los minis
my %MINIS=ReadFasta($outname,$dir2,$list);#INPUT los .bbh OUTPUT=interseccion de todos en  inter.todos

foreach my $PegId(keys %MINIS){	
#	print "$PegId\n";
#	print "$PegId->$MINIS{$PegId}\n";
	}


## Hacer un hash con el id de cada gen por ortologia
## Imprimir un fasta con esos ids ordenados por ortologos
## Imprimir lista Ortho all
byOrthologues($outname,$DesiredGenes,\%MINIS,$outdir,$dir2);

## Hacer Hash con los id de cada gen en el core por organismo
## Imprmir Fasta con los ids ordenados por organismo (Cada organismo con todos sus genes en el core
byOrganism($outname,$DesiredGenes,\%MINIS,$outdir,$dir2);
print "Done!\n";


####################################
##GENERA FASTA de las intersecciones
####################################


sub ReadFasta{
	my $outname=shift;
	my $dir=shift;
	my $listaname=shift;
	my %hashFastaH;

	my @ALL=split(",",$listaname);

	#print "\n$dir/$listaname\n";
#	open (FAA, "$dir/$listaname") or die $!;
#	print"Lista abiertai\n";## Lista con todos los nombres de faa en el directorio

	my $headerFasta="";

	foreach my $mini(@ALL){
		chomp($mini);
		####### llena hash con encabezado-secuencia#####
		open (CU, "$dir/$outname/MINI/$mini.faa") or die "Could not open $dir/$outname/$mini.faa $!\n\n";
		#print "$dir/MINI/$mini.faa\n";
		
  		while(<CU>){	
    			 if($_ =~ />/){
       				chomp;
       				$headerFasta=$_."|$mini";
				#print "$headerFasta\n";
		#	print "Enter to continue\n";
		#	my $pause =<STDIN>;
     			}
     			else{
       				$_ =~ s/\*//g;
				if (! -exists $hashFastaH{$headerFasta}) {$hashFastaH{$headerFasta}="";}
       				$hashFastaH{$headerFasta}= $hashFastaH{$headerFasta}.$_;
			#	print "$headerFasta => $hashFastaH{$headerFasta}\n";
  
     			}
		 }#end while CU
	}#end foreach ælistaname ############# Termina de llenar has con encabezado-secuencia
	################################################
	close CU;
	return %hashFastaH;
}

#_______________________________________________________________________
sub byOrthologues{
	my $outname=shift;
	my $DesiredGenes=shift;
	my $refMINIS=shift;
	my $outdir=shift;
	my $dir=shift;
	#my %byOrtho;

	open (ALL, "$dir/$outname/$DesiredGenes") or die "Couldnt open  $dir/$outname/$DesiredGenes \n$!";
	my $count=1;

 	foreach my $linea(<ALL>){

		open (FASTAINTER, ">$outdir/FASTAINTER/$count.interFastatodos") or die "Couldnt open file $count interFastatodos $!";
  #		print "Writing: $outdir/FASTAINTER/$count.interFastatodo\n";
		open (LISTA, ">>$outdir/lista.ORTHOall") or die "Cant print lista ortho all $!";
		print LISTA "$count.interFastatodos \n";

		chomp $linea;
	#	print "Orthologue $count in core\n";
		my @sp=split (/\t/,$linea);
		foreach my $gen (@sp){
			$gen=">$gen";
			#print "#$gen#\n";
			#print "MINIS: #$refMINIS->{$gen}#\n";
			if(exists $refMINIS->{$gen}){
			#	print("Encontrado!\n");
				print FASTAINTER "$gen\n$refMINIS->{$gen}";
     				}
     			else{
       			#	print "NOT FOUND!!!\n*$gen\n**$refMINIS->{$gen}\n";
     				}
			}
		close FASTAINTER;
		close LISTA;
		$count++;
#		print "\n";
		}
	close ALL;
}

#_______________________________________________________________________

sub byOrganism{
	my $outname=shift;
	my $DesiredGenes=shift;
	my $refMINIS=shift;
	my $outdir=shift;
	my $dir=shift;
	open (ALL, "$dir/$outname/$DesiredGenes") or die "Couldn open $dir/$outname/$DesiredGenes \n$!";
	my %Orgs;
	my $count=1;

 	foreach my $linea(<ALL>){ ## para cada linea en el core 
		chomp $linea;
		my @sp=split (/\t/,$linea);
	#	print "Linea $count \n ";
		$count ++;		
		foreach my $gen (@sp){		## obtengo en orden todos sus genes
			$gen=">$gen";
	#		print "#$gen#\n";
			
			if ($gen=~/\>fig\|\d*.\d*\.peg\.\d*\|(\d*\_\d*)$/){
	#			print "Este gen tiene organismo #$1#\n";		
				if (!exists $Orgs{$1}){
					$Orgs{$1}=[];
	#				print "Organismo #$1# es un  array\n";
					}
			
				push(@{$Orgs{$1}},$gen);
				}
	#		print "MINIS: #$refMINIS->{$gen}#\n";
		}	
	}
	close ALL;

	foreach my $orgNumber(keys %Orgs){
    		open (FASTAINTERORG, ">$outdir/FASTAINTERporORG/$orgNumber.interFastatodos") or die "Couldn't open orthologues file $orgNumber $!"; 
     		if(exists $Orgs{$orgNumber}){
			foreach my $gen (@{$Orgs{$orgNumber}}){
     				if(exists $MINIS{$gen}){
 	      				print FASTAINTERORG "$gen\n$MINIS{$gen}";
					}
				else{
	#				print "NOT FOUND por ORG\n$gen\n$MINIS{$gen}\n";
					}
				}
     			}
		else{
         #     		print "Organism $orgNumber doesn't have an array with its genes!!\n";
			}
  		close FASTAINTERORG;
 	}#end while foreach
}

