#!/usr/bin/perl
use strict;
use warnings;

###### This script add genome number to fasta headers
##     Needs RAST.IDs

my $genome_dir=$ARGV[0];
my $RAST_IDs=$ARGV[1];
my $outfile="Concatenados.faa";

Concatenar($RAST_IDs, $genome_dir, $outfile);

##################### Subs 	#############################
#_______________________________________________________
sub Concatenar{
	my $Idsfile=shift;
	my $genome_dir=shift;	
	my $outfile=shift;

	open(OUT, ">$outfile") or die "Couldn't open file $outfile $!\n";
	open(ALL, "$Idsfile") or die "I Couldn't open $Idsfile$!\n";

	while (my $line= <ALL>){
		chomp $line;
		my @ids=split(/\t/,$line);
		my $jobId=$ids[0];
		print "JobId = #$ids[0]# Name =$ids[2]\n";
	
 
		open(EACH, "$genome_dir/$jobId.faa") or die "$genome_dir/$jobId.faa does not exists $!";


  		while(my $line2=<EACH>){
			#print "Line =$line2\n"; 
			#print "Enter to continue\n"; 
			#my $pausa=<STDIN>;
   			chomp($line2);
    			if($line2 =~ />/){
      				print OUT "$line2|$jobId\n";
      				#<STDIN>;  
    				}
    			else{
		      		print OUT "$line2\n";
   				 } 
    	  		}#end while EACH
  		close EACH;
		}
	close ALL;
	close OUT;
	}

