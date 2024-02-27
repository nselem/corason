#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Cwd;

#my $dir2=&Cwd::cwd();
my $name="CORASON";                       ##Name of the group (Taxa, gender etc)
my $outname=$ARGV[0];
my $dir2=$outname;

###############################################################################################################
############Este archivo remueve saltos de lineas dobles
#################################################################################################################
#################### Global variables 
  my $directory =  "$dir2/$name/CONCATENADOS";
##################################################################################################################
`perl -pi -e "s/^\n//" $directory/*`;            ####Removiendo saltos dobles                    

