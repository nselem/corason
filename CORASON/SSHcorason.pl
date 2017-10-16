#!/usr/bin/perl
use strict;

my $yourquery=$ARGV[0]; 
my $yourRAST=$ARGV[1]; 
my $yourspecial=$ARGV[2];

print "corason.pl -q $yourquery -rast_ids $yourRAST -s $yourspecial\n";
system "corason.pl -q $yourquery -rast_ids $yourRAST -s $yourspecial\n";
