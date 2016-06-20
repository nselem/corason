#!/usr/bin/perl
use strict;
use warnings;

my $outname=$ARGV[0];
#print "Outname directory is $outname\n";
my @CLUSTERS=qx/ls $outname\/*.input/; 	## Read all input Uncomment to read all

my $list="";
my $relevant=0; #number of clusters with more than one coincidence
my $coincidences=2;
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
#	print "$context : _$firstline _\n";
#	print HITS "$firstline\n";

	my @content=split(/\n/,$column);
	my %seen;
	my @unique = grep { not $seen{$_} ++ } @content;
	#print "@unique\n";
	if (@unique>=$coincidences){
		#print "OK\n";
		$relevant++;	
		$list=$list.$file.",";
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
#open (FILE,"globalsFormat.pm") or die "Couldnt open file globals $!";
#open (NEW,">globals2.pm") or die "Couldnt open file globals $!";
#print "Modificando el modulo\n";
#for my $line (<FILE>){
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

