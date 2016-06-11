#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Cwd;

my $dir2=&Cwd::cwd();
my $name=pop @{[split m|/|, $dir2]};                       ##Name of the group (Taxa, gender etc)

###############################################################################################################
############Este archivo remueve saltos de lineas dobles
#################################################################################################################
#################### Global variables 
  my $directory =  "$dir2/$name/CONCATENADOS";
##################################################################################################################
`perl -pi -e "s/^\n//" $directory/*`;            ####Removiendo saltos dobles                    

