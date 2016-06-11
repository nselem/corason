#!/usr/bin/perl
use strict;
use warnings;
################################################################
# $perl cor_formatdb.pl genome_dir RAST.IDs
##############################################################

my $genome_dir=$ARGV[0];
my $RAST_IDs=$ARGV[1];

my $cat_file="Concatenados.faa";
my $database="ProtDatabase";

print "Now we will format database:\n";
if (-e "$cat_file"){
	print "Removing old files\n";
	`rm $cat_file`;
	}

print "Indexing database\n";
`header.pl $genome_dir $RAST_IDs`;

print "Making blast database \n";
`makeblastdb -in $cat_file -dbtype prot -out $database.db`;
print "La base recibio formato\n\n";

