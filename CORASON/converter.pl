#!/usr/bin/env perl
use strict;
use warnings;

my $file=$ARGV[0];
my %dict=readFile($file);
$file=~s/\.txt//;
writeStockholm($file,\%dict);

######## Subs #######################################################

sub writeStockholm{
	my $file=shift;
	my $refDict=shift;
	my @ids = keys %$refDict;
	my $size = @ids;
	my $length;
	my $currentPos=0;

	open OUTPUT, ">$file.stockholm" or die "couldn't create file $file.stockholm $!\n";
	print OUTPUT "# STOCKHOLM 1.0";
	while($size>0){
		for my $iD (@ids){
			if(length($refDict->{$iD})<=$currentPos)
			{
				$size--;
			}else{
				print OUTPUT "\n";
				print OUTPUT $iD."\t";
				print OUTPUT substr $refDict->{$iD},$currentPos,50;				
			}
		}
		print OUTPUT "\n";
		$currentPos+=50;
	}
	print OUTPUT "//";
	close(OUTPUT);
}


#_______________________________________________________________________________
sub readFile{
	my $file=shift;
	my %dict;
	my $id;

	open FILE, $file or die "couldn't open filei $file\n";

	while(<FILE>){
		$_=~s/\s+//g;
		if($_=~/^>/)
		{
			$_=~s/^.//s;
			$id = $_; 
			$dict{$id} ='';
		}else{ 
			$dict{$id}.=$_;
		}

	}
	close(FILE);
	return %dict;
}

