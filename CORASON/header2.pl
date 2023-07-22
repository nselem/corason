#!/usr/bin/env perl
use strict;
use warnings;

###### This script add genome number to fasta headers
##     Needs RAST.IDs

my $genome_dir="MINI";
my $lista=$ARGV[0];
my $outname=$ARGV[1];
my $outfile="Concatenados.faa";

Concatenar($outname,$lista,$genome_dir,$outfile);

sub Concatenar{
	my $outname=shift;
        my $list=shift;
        my $genome_dir=shift;
        my $outfile=shift;

	my @ALL=split(",",$list);
        open(OUT, ">$outname/$genome_dir/$outfile") or die "Couldn't open file $outname/$genome_dir/$outfile $!\n";

        foreach my $HitId(@ALL){
                chomp $HitId;
                #my @ids=split(/\t/,$line);
                #my $HitId=$ids[0];
                #print "JobId = #$ids[0]# Name =$ids[2]\n";


                open(EACH, "$outname/$genome_dir/$HitId.faa") or die "$outname/$genome_dir/$HitId.faa does not exists $!";


                while(my $line2=<EACH>){
                        #print "Line =$line2\n"; 
                        #print "Enter to continue\n"; 
                        #my $pausa=<STDIN>;
                        chomp($line2);
                        if($line2 =~ />/){
                                print OUT "$line2|$HitId\n";
                                #<STDIN>;  
                                }
                        else{
                                print OUT "$line2\n";
                                 }
                        }#end while EACH
                close EACH;
                }
        close OUT;
        }


