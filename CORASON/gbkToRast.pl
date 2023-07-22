#!/usr/bin/env perl
use strict;
use warnings;
#############################################################################################
# this script will turn gbk's from BigScape into CORASON inputfiles Faa and txt
# Input: Jorge's list of compound BGCs clustered on families
#
# Output: By each compound a folder with its correspondent GENOMES and RastIds
###########################################################################################
my $file =$ARGV[0]; ##File from Big-Scape with the compouns BGCs sorted by families
my $dir=$ARGV[1]; ## ADdress where the gbks are
$dir=~s/\/$//; ## just in case take out the /


my %COMPOUNDS=getCompoundsBGCs($file); ## Creates a HAsh with compound names as key and an arrays of BGC's list
cleaning();
#################### main ##########################if
foreach my $key ( sort keys %COMPOUNDS){
	system "mkdir BIG_OUTPUT/$key";
	system "mkdir BIG_OUTPUT/$key/GENOMES";
	call_transform($key,$dir,\%COMPOUNDS);
	print "\n";
}



exit;

################################### SUBS #####################################
sub cleaning{

	if (-e "BIG_OUTPUT"){
		print "cleaning";
		system("rm -r BIG_OUTPUT");
		system("rmdir BIG_OUTPUT");
		}
	else {
		system("mkdir BIG_OUTPUT");
		}
	}
#__________________________________________________________
sub getCompoundsBGCs{
	my %HASH;
	my $file=shift;
	open (FILE,"$file") or die "Couldnt opne that $file \n $!";
	my $name;
	my $before=<FILE>;
	foreach my $line (<FILE>){
		chomp $line;
		if($line=~/Compound/){
			$name=$before;
			chomp $name;
			$name=~s/Compound//;
#			print "Name $name\n";
			$HASH{$name}=();
			}
		else{
			my @st=split (/\t/,$line);
			if($st[1]){
#				print "$st[0]\n";
				push(@{$HASH{$name}},$st[0]);
				}
			}

			$before=$line;
		}
	return %HASH;
	}


#_________________________________________________________
sub boolNCBI{
my $bool=0;
my $name=shift;
my $short=substr($name,0,4);
my $short2=substr($name,4,2);
if ($short=~/[A-Z]{4}/ and $short2=~/\d{2}/){$bool=substr($name,0,6);}
#print "short $short $short2 bool $bool\n";
return $bool;
}
#____________________________________
sub call_transform{
	#system "mkdir BIG_OUTPUT/$key/GENOMES";
	my $compound=shift;
	my $dir=shift;
	my $refHASH=shift;
	my $cont=100000;
	open (IDS, ">BIG_OUTPUT/$compound/Rast.IDs");
	foreach my $file (@{$refHASH->{$compound}}){
		chomp $file;
		my $bool=boolNCBI($file);
		my $name=$file;
		$name=~s/$dir//;
		$name=~s/\///;
		$name=~s/\.gbk//;
		my $number=6-length $cont;
		$number="0"x$number.$cont;
		print  IDS "$number\t666666.$number\t$name\n";
		my $gbk_file="";
		if($bool ne 0){
		$gbk_file=qx/ls $bool*\/$name*.gbk/;
		chomp $gbk_file;}
		else{
			$gbk_file= "$dir/$name.gbk";}
		print(" perl gbkToRast.pl $gbk_file $number $name $compound\n\n");
		if (-e $gbk_file){
			print "happy\n";
			system(" perl gbkToRast.pl $gbk_file $number $name $compound\n\n");
		}
#		system(" perl gbkToRast.pl $file $number $name");
		#my $pause=<STDIN>;	
		$cont++;
		}
	close IDS;
	}

