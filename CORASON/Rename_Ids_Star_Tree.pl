#!/usr/bin/perl
use strict;
use warnings;

my $verbose;

`rm RightNames.txt`;
open (NAMES,"RAST.IDs") or die "Couldn't open NAMES file $!";
open (SEQUENCE,"SalidaConcatenada.txt") or die "Couldn't open Concatenados file $!";
open (BAYES,">>RightNames.txt") or die "Couldn't open RightNames file $!";

my %SEQUENCES;
my %NAMES;


#########################################################################
####### Main program ####################################################

readNames(\%NAMES);
readSequence(\%SEQUENCES,\%NAMES);
#print $len;

close NAMES;
close SEQUENCE;
close BAYES;

##########################################################################
##########3 subs #######################################3

sub readNames{
my $refNAMES=shift;
#my $count=1;
foreach my $line (<NAMES>){
	chomp $line;
	my @st=split("\t",$line);
	my $org=$st[0];
#	$count++;
	my $name=$st[2];
#	$name=~s/\r//;
	$name=~s/[)(,.-]=/_/g;
	$name=~s/\s/_/g;	
	$name=~s/__/_/g;
	$refNAMES->{$org}=$name;
	if($verbose){print "$org -> $refNAMES->{$org}!\n";}
	}
}
#######################################################3

sub readSequence{
	my $refSEQUENCES=shift;
	my $refNAMES=shift;
#	my $len;

	my $Org="Empty";
	foreach my $line (<SEQUENCE>){
		chomp $line;
		 if ($line=~m/>/){
                        $Org=$line;
			my $peg="";
			if ($Org=~/org(\d*)\_(\d*)$/){
                        	#$Org=~s/>org//;
                        	#$Org=~s/\_\d*$//;
				$Org=$1;
				$peg=$2;
                      		#$Org=~s/peg\_\d*$//;
                        	if($verbose){print "Org #$Org# Peg $peg\n";}
				}
                        my $name=$refNAMES->{$Org}."_peg_"."$peg"."_org_"."$Org";
                        print BAYES ">$name\n";
                        }
                else{# 
			$line=~s/\s//g;
#			$len = map $_, $line =~ /(.)/gs; 
			#print "Len $len\n";
                        print BAYES "$line\n";

                        }
		}
#	return $len;	
	}
