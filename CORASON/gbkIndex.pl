#!/usr/bin/perl
use lib '/usr/local/lib/perl5/site_perl/5.20.3';
use strict;
use Bio::SeqIO;
use Bio::Species;
#############################################################################################
# this script will turn gbk's from BigScape into CORASON inputfiles Faa and txt
# Input: Jorge's list of compound BGCs clustered on families
#
# Output: By each compound a folder with its correspondent GENOMES and RastIds
###########################################################################################
my $dir=$ARGV[0]; ## ADdress where the gbks are
$dir=~s/\/$//; ## just in case take out the /
my @files=qx /ls $dir/;

#print "Directory $dir\n";

foreach my $file (@files){
	#print $file;
	}
cleaning();

#################### main ##########################if
my $count=100000;
foreach my $file ( @files){
	chomp $file; #print "File $file\n";
	my $ext= substr $file, -3;
#	print "$file y extension $ext\n";
	if ( $ext eq "gbk"){
#		print "file $file will be proceesed\n";
		call_transform($file,$dir,$count);
			$count++;
		}
}

################################### SUBS #####################################
sub cleaning{

	if (-e "/usr/src/CORASON/GENOMES"){
		#print "cleaning";
		system("rm -r /home/output/CORASON/GENOMES");
		system("rmdir /home/output/GENOMES");
		}
		system("mkdir /home/output/GENOMES");
	if (-e "Corason_Rast.IDs"){
		print "cleaning old files....\n";
		system("rm -r Corason_Rast.IDs");
		}
	}
#__________________________________________________________
sub call_transform{
	#system "mkdir CORASON_GENOMES";
	my $file=shift;
	my $dir=shift;
	my $cont=shift;
		$cont++;
	open (IDS, ">>Corason_Rast.IDs");
	chomp $file;
	my $name=$file;
	$name=~s/$dir//;
	$name=~s/\///;
	$name=~s/\.gbk//;
	my $seqio_obj = Bio::SeqIO->new(-file => "$dir/$file",  -format => "genbank" );

	##leer todas las secuencias oe file by seq obj
	#while (my $seq_object = $seqio_obj->next_seq ){
    		## aumentar contador
	my $number=6-length $cont;
	$number="0"x$number.$cont;
		#my $seq_object = $seqio_obj->next_seq;
	#	my $org="";
	#	my $accesion;

        #	$accesion= $seq_object->accession . "\n"; ##Getting accesion
        #	if ($seq_object->species){$org= $seq_object->species->binomial();}; ##Getting ORGANISM

	#	if (!$org){
	#		for my $feat_object ($seq_object->get_SeqFeatures) {
	#		if($feat_object->primary_tag eq "source"){
 	#	   		for my $tag ($feat_object->get_all_tags) {
	#				if($tag eq "organism"){
#		        		#	print "  tag: ", $tag, "\n";
 #     							for my $value ($feat_object->get_tag_values($tag)) {
  #         							#print "    value: ", $value, "\n";
#								$org=$value;
#								next;
#								}
#							}
#						#if($org){next;}
#       						 }
#    					}
#				}
#			}
#		chomp $org; chomp $accesion;
#		print  "$number\t666666.$number\t$org $accesion \n";
		print  IDS "$number\t666666.$number\t$file \n";

		print(" gbk_to_fasta.pl $dir $file $number\n");
		system("gbk_to_fasta.pl $dir $file $number\n");
	#}
	close IDS;
	#return $cont;
	}

