#!/usr/bin/perl
use strict;

my $yourquery=$ARGV[0]; 
my $yourRAST=$ARGV[1]; 
my $yourspecial=$ARGV[2];
my $antiSMASH=$ARGV[3];

print "corason.pl -q $yourquery -rast_ids $yourRAST -s $yourspecial -a $antiSMASH\n";
system "corason.pl -q $yourquery -rast_ids $yourRAST -s $yourspecial -a $antiSMASH\n";
