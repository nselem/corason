#!/usr/bin/env perl
use strict;
use warnings;
my ($yourquery,$yourRAST,$yourspecial) = @ARGV;

print "corason.pl -q $yourquery -rast_ids $yourRAST -s $yourspecial\n";
system "corason.pl -q $yourquery -rast_ids $yourRAST -s $yourspecial\n";
