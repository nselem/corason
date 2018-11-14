#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
no warnings 'experimental::smartmatch';

#####################################
#REQUERIMIENTOS:
#-LISTA DE GENOMAS
#####################################

my $dir=&Cwd::cwd();
#my $NAME=pop @{[split m|/|, $dir]};                       ##Name of the group (Taxa, gender etc)
my $NAME="CORASON";                       ##Name of the group (Taxa, gender etc)
#my $infile=$name;
#my $outdir="$dir2/$infile";
my $list=$ARGV[0];
my $num=$ARGV[1];
my $outname=$ARGV[2];
#my $DesiredGenes="Core";

## Leer por subsistema Replicar el trabajo de RAST
## Leer por Fig (A quién pertenece ese fig) F
###################################################################
## Archivos tsv

#my $dir="/home/nelly/CLAVIBACTER";

###################################################################
my $Mode= "F"; ## Dado un Fig Cual es su funcion
#my %SUBSYSTEM; 

###################################################################

sub readSubsystem;
sub readFigs;
sub readList;
###################################################################
##################### MAin    #####################################
###################################################################
#my $Lista=$LIST2; #Globals
#my $list=listas($NUM2,$Lista);  #$list stores in a string the genomes that will be used
my @LISTA=split(",",$list);

my $FUNCTION_PATH="$outname/$NAME/FUNCTION";
unlink( $FUNCTION_PATH);
`rm -r $FUNCTION_PATH`;
`mkdir $FUNCTION_PATH`;
#print "$FUNCTION_PATH\n";


foreach my $num (@LISTA){
	EscribeSalida($outname,$num);
	}
####################################################################
####################################################################
sub EscribeSalida {
	my $outname=shift;

	my $num=shift;
	my %FIG; #Fig, Category, SubCategory # Subsystem #Role 
	my @CORE;
	my @COMPLEMENT;

	my @sp=split('_',$num);
	my $org=$sp[0];
	#print "Numero de peg de cluster #$num# Organismo a buscar en txt #$org# \n";

	my $ReactionFile="GENOMES/$org\.txt";  ## File cvs from RAST with ALL the reactions (From the spreadsheet reaction)
	#my $FigsFile="$dir/$num.figs"; ## File with the figs or feachures id for wich we want the function
	my $genome_file="$outname/MINI/$num.faa";

	my $core_file="$outname/$NAME/FASTAINTERporORG/$num.interFastatodos";
	#print "El core $core_file $dir/$NAME/FASTAINTERporORG/$num.interFastatodos \n";
	#print"En lista $dir/$NAME/FASTAINTERporORG/$num.interFastatodos\n";
	#print "$genome_file\n";	

	my @Genome=readList($genome_file);
	@CORE=readList($core_file);  ## Fills Querys with the querys figs  ##Cambiarlo al interFAsta todos
	@COMPLEMENT=complement(\@Genome,\@CORE);

	#foreach my $gen (@Genome){print "$gen\n";}
	#foreach my $gen (@CORE){print "$gen\n";}
	#foreach my $gen (@COMPLEMENT){print "$gen\n";}
	
	#print "I will work on reaction File $ReactionFile\n\n";
	readSubsystem($ReactionFile,\%FIG);  #Stores en FIGCORE los figs del genoma

	if ($Mode =~/F/){
#		HeadF(); #Gene	#Subsystem	#Role	# 
		my $core=1; my $complement=0;
		mainFig($outname,$num,\%FIG,\@CORE,$core,$NAME);   #escribe Salida
		mainFig($outname,$num,\%FIG,\@COMPLEMENT,$complement,$NAME);   #escribe Salida
		}
}
###################################################################
sub complement{
	my $refContent=shift;
	my $refCore=shift;
        my @Complement;

	foreach my $id (@{$refContent}){
#	print "$id \n";
		if($id~~@{$refCore}){
	#		print ("$id not in complement\n")
			}
		else{
			push(@Complement,$id);
#		print "$id is in complement\n";
			}

		}
	return @Complement;
	}

sub listas{
	my $NUM=shift;
	my $LISTA=shift;
	my $lista="";

	if ($LISTA){ 
		#print "Lista de genomas deseados $LISTA";
		$lista=$LISTA;
		}
	else {
		for( my $COUNT=1;$COUNT <= $NUM ;$COUNT++){
			$lista.=$COUNT;
			if($COUNT<$NUM){
				$lista.=",";
				}
			}
		}
	return $lista;
		
	}
#_______________________________________________________________________________________________

sub readList{

	my $input=shift;
	my @LContent;
	open (LISTA,"$input") or die "could not open file $input $!";
        my @Genome=<LISTA>;
	foreach my $line (@Genome) {
		chomp $line;
		if ($line=~/>/ ){
		$line=~s/\|\d*\_\d*$//g;
		$line=~s/>//g;
	#	print("#$line#\n");
			push(@LContent,$line)
			}
		};
	return @LContent;
}
#____________________________________________________________________




############################ Subs #####################################
#Category	Subcategory	Subsystem	Role/EC	Features
sub HeadF{
	#print("feature_id\tcontig_id\ttype\tlocation\tstart\tstop\tstrand\tfunction\taliases\tfigfam\tevidence_codes\tnucleotide_sequence\taa_sequence\n");
	}

sub readFigs{ # Read wich figs are given in search of function.- fills the array QUERYS
	my $input=shift;
	my @ARRAY;
	my @LContent;
	open (LISTA,"$input") or die "Could not open file $input : $!";
	my @Figs=<LISTA>;
	foreach my $fig (@Figs) {
		chomp $fig;
		#print "#$fig#\n";
		push(@ARRAY,$fig);
		}
	return @ARRAY;
	}


sub readSubsystem{
		 ## Get the full reaction and function information from the organism
	my $input=shift;
	my $refFig=shift;
	my @LContent;
	open (LISTA,"$input") or die "Could not open file $input : $!";

	#my @Reactions=<LISTA>;
	while( my $line = <LISTA>) {
		$line=~ s/\r//g;   ##Linea salvadora de Cristian para quitar basura que interfiere con el chomp
		chomp ($line);
		#print ">$line#\n";
		my @Parts=split("\t",$line);

		chomp @Parts;

		my $contig_id=$Parts[0];
		my $feach=$Parts[1];
		my $type=$Parts[2];
		my $location=$Parts[3];
		my $start=$Parts[4];
		my $stop=$Parts[5];
		my $strand=$Parts[6];
		my $function=$Parts[7];
		my $aliases=$Parts[8];
		my $figfam=$Parts[9];
		my $evidence_codes=$Parts[10];
		my $nucleotide_sequence=$Parts[11];
		my $aa_sequence=$Parts[12];
		#print "PART11: $Parts[11]\n";
		#print "PART12: $Parts[12]\n";
		#my @Seq;
		#if($Parts[11]){
			#@Seq=split("",$Parts[11]);
			#}
		#my $nucleotide_sequence=$Seq[0];
		#my $aa_sequence=$Seq[1];

		
		if($feach=~/fig/){
			chomp $feach;	
			$feach=~s/^\s*//;	
			$feach=~s/\n//;	
			$refFig->{$feach} = [$contig_id,$type,$location,$start,$stop,$strand,$function,$aliases,$figfam,$evidence_codes,$nucleotide_sequence,$aa_sequence]; 
			}
	
			#print "Contig: $contig_id\n";				
			#print "Cat: $Category\n";				
			#print "Cat: $Category\n";				
			#print "Cat: $Category\n";				
			#print "Cat: $Category\n";				
			#print "Cat: $Category\n";				
			#print "Cat: $Category\n";				
			#print "Sub: $Subcategory\n";
			#print "Subsystem: $Subsystem\n";
			#print "Role: $Role\n";
			#if ($EC ) {print "EC: $EC\n";}
			#else {print "EC: empty\n";}
			#print("\n");
		}
	close LISTA;
	}

sub mainFig{  ## Returns the function for each gene (Sorted by Fig number)
	my $outname=shift;
	my $num=shift;
	my $refFig=shift;
	my $refQUERYS=shift;
	my $core=shift;
	my $NAME=shift;

	my @QUERYS=@{$refQUERYS};

	my @UNSORTED;
	my @SORTED;
	my %PEGS;

	if ($core==1){	open (OUTFILE,">$outname/$NAME/FUNCTION/$num.core.function") or die "Could not open CORE function file $outname/$NAME/FUNCTION/$num.core.function $!";}
	if ($core==0){	open (OUTFILE,">$outname/$NAME/FUNCTION/$num.complement.function") or die "Could not open COMPLEMENT function file $outname/$NAME/FUNCTION/$num.complement.function $!";}
	


	#foreach my $fig (keys %$refFig){
	foreach my $fig (@QUERYS){
	#	print ">$fig<\n";
		my $peg= $fig;
		if ($peg=~/peg/ ){$peg=~s/.+peg.//;}
		else{ $peg=~s/.+rna.//;	}

		push(@UNSORTED,$peg);
		$PEGS{$peg}=$fig;
	#	print "$peg, => #$PEGS{$peg}#\n\n";
		}

	@SORTED = sort { $a <=> $b } @UNSORTED;

	foreach my $peg (@SORTED){
		my $fig=$PEGS{$peg};
		if (exists $refFig->{$fig}){
			my $contig_id=$refFig->{$fig}[0];
			#my $feach->{$fig}[1];
			my $type=$refFig->{$fig}[1];
			my $location=$refFig->{$fig}[2];
			my $start=$refFig->{$fig}[3];
			my $stop=$refFig->{$fig}[4];
			my $strand=$refFig->{$fig}[5];
			my $function=$refFig->{$fig}[6];
			my $aliases=$refFig->{$fig}[7];
			my $figfam=$refFig->{$fig}[8];
			my $evidence_codes=$refFig->{$fig}[9];
			my $nucleotide_sequence=$refFig->{$fig}[10];
 			my $aa_sequence=$refFig->{$fig}[11];
			#print "$fig\n$contig_id\n$type\n$location\n$start\n$stop\n$strand\n$function\n$aliases\n$figfam\n$evidence_codes\n$nucleotide_sequence\n$aa_sequence";
			print OUTFILE "$fig\t$function\t$contig_id\t$type\t$location\t$start\t$stop\t$strand\t$aliases\t$figfam\t$evidence_codes\t$nucleotide_sequence\t$aa_sequence\n";
#			print "$fig\t$contig_id\t$type\t$location\t$start\t$stop\t$strand\t$function\t$aliases\t$figfam\t$evidence_codes\t$nucleotide_sequence\t$aa_sequence";
			}
		else{ #print "$fig No function asigned in this reaction file\n";
			}
		}
	close OUTFILE;
	}

