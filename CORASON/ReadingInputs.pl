#!/usr/bin/perl
use strict;
use warnings;

###############################################################################################
## This script keeps only files that have at least 2 enzymes on common with the Best Cluster
## It also prints a frequency table of each enzyme inside the gen cluster
##

my $outname=$ARGV[0];
#print "Outname directory is $outname\n";
my @CLUSTERS=qx/ls $outname\/*.input/; 	## Read all input Uncomment to read all
my %FREQ;

if(-e "$outname/GBK"){system("rm -r $outname/GBK");}
system(mkdir "$outname/GBK");

my $list="";
my $relevant=0; #number of clusters with more than one coincidence
my $coincidences=3; ## Becouse 0, and 1 are already coincidences
#open (HITS,">PrincipalHits") or die "couldnt open hits file";
#open (FASTA,">PrincipalHits.FASTA") or die "couldnt open hits file";

foreach my $context(@CLUSTERS){
	chomp $context;
	my $file=$context;
	$file=~s/.input//;
	$file=~s/$outname\///;
	#print "$context\n";
	my $column=`cut -f4 $context`;
	my $firstline=`head -n 1 $context | cut -f7 `;
	chomp $firstline;

	my @content=split(/\n/,$column);
	
	my %seen;
	my @unique = grep { not $seen{$_} ++ } @content;
	#print "@unique\n";

	if (@unique>=$coincidences){
		#print "OK\n";
		$relevant++;	
		$list=$list.$file.",";

		###### Geting the frequency for frequency tables
		foreach my $num(@unique){
			if(-exists $FREQ{$num}){$FREQ{$num}++;}
			else{$FREQ{$num}=1;}
			}
		##### Printing the GBK
		system("GbkCreator.pl $file $outname");
		#my $pause=<STDIN>;
		#print "pause\n";
			
		}
	else {	
		#print "Voy a remover $file\n";
		if (-e "$outname/$file.input"){`rm $outname/$file.input`;		}
		if (-e "$outname/$file.input2"){`rm $outname/$file.input2`;}
		if (-e "$outname/MINI/$file.faa"){`rm $outname/MINI/$file.faa`;}
		}
	#print "#################\n";
	}
chop $list;

print "$relevant\t$list";
open (FILE,">$outname/Frequency") or die "Couldnt open file Frequency $!";

#open (NEW,">globals2.pm") or die "Couldnt open file globals $!";
#print "Modificando el modulo\n";

foreach my $family (sort keys %FREQ){
	print FILE"$family\t$FREQ{$family}\n";
	}
#	chomp $line;

#	if ($line=~/LIST/){
#	$line=~s/\"\"/\"$list\"/;	
#	}
#	if ($line=~/NUM/){
#	$line=~s/\"\"/\"$relevant\"/;	
#	}
#	print NEW "$line\n";
#}


#close FILE;
#close NEW;
#close HITS;
#close FASTA;
#print "El archivo globals2 fue reeescrito\n";
#print "Se buscaran aminoácidos de hits principales encaso de No core\n";

