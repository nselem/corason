#!/usr/bin/perl
use strict;
use warnings;

#Renombrar arbol
my $file=$ARGV[1];
my $outname=$ARGV[0];
my $RAST_IDs=$ARGV[2];
if (-e "$outname/$file.txt"){`rm $outname/$file.txt`;}
open (NAMES,"$RAST_IDs") or die "Couldn't open NAMES file $RAST_IDs $!";
open (SEQUENCE,"$outname/$file") or die "Couldn't open $outname/$file file $!";

if($file=~/gb/){
	$file=~s/\.muscle-gb//;
	open (BAYES,">>$outname/RightNames$file.txt") or die "Couldn't open $outname/RightNames$file.txt file $!";
}
else{
	$file=~s/\.muscle//;
	open (BAYES,">>$outname/RightNames$file\_Unshaved.txt") or die "Couldn't open $outname/RightNames\_Unshaved$file.txt file $!";
}
my %SEQUENCES;
my %NAMES;

#########################################################################

readNames(\%NAMES);
readSequence(\%SEQUENCES,\%NAMES);
close NAMES;
close SEQUENCE;
close BAYES;
##########################################################################
sub readNames{
my $refNAMES=shift;
#my $count=1;
foreach my $line (<NAMES>){
	chomp $line;
	my @st=split("\t",$line);
#	my $org=$count;
#	$count++;
	my $jobId=$st[0];
	my $name=$st[2];
	$name=~s/[\[\)\(\,\.\-\]\=]/_/g;
	$name=~s/\s/_/g;	
	$name=~s/__/_/g;
	$refNAMES->{$jobId}=$name;
#	print "$jobId¡$refNAMES->{$jobId}!\n";
	}
}

sub readSequence{
	my $refSEQUENCES=shift;
	my $refNAMES=shift;

	my $Org="Empty";
	foreach my $line (<SEQUENCE>){
		chomp $line;
		if ($line=~m/>/){
#			print "LINE $line\n";
			$Org=$line;
			my $peg="";
			if($Org=~/peg/){
				$Org=~s/peg_(\d*)//;
				$peg=$1;
				}
			$Org=~s/>_org//;
#			print "Org :#$Org#\n Peg #$peg#\n Name #$refNAMES->{$Org}#\n";
			my $name=$refNAMES->{$Org}."_peg_".$peg."_org_"."$Org";
			print BAYES ">$name\n";
			}		
		else{#	
			print BAYES "$line\n";
			
			}
		}
	}
