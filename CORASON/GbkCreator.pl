#!/usr/bin/perl
use strict;
use lib '/usr/local/lib/perl5/site_perl/5.20.3';
use Bio::SeqFeature::Generic;
use Bio::Seq;
use Bio::SeqIO;
use Bio::Species;
use Cwd qw(cwd);
###########################################################################
# Get a Gen Id and a File Id (Genome.txt) and extracts 20 genes 
# (10 each side) on genebank format
###########################################################################

my $genId=$ARGV[0]; ## something like fig|6666666.279404.peg.1
my $outname=$ARGV[1];
my $scripts=$ARGV[2];

my $genomes_dir="/home/output";
if($scripts eq 'CORASON'){$genomes_dir=cwd;}
#chomp $genId; 
#print "GenId is $genId\n";
#my $pause=<STDIN>;
$genId=~/(\d*)_(\d*)/; my $genNumber=$2; my $genomeId=$1;
#print "number $genNumber genome $genomeId\n";

my %TXT; 
readingTxtFile($genomeId,\%TXT); 

my @BGC=fillinIdsArray($genId,$genomeId); ## I need to change this instead of numbers go for coordinates !!
#foreach my $id (@BGC){print"$id\n";}

AnotateGBK($genomeId,$genId,\%TXT,\@BGC);

sub AnotateGBK{
	my $genomeId=shift;
	my $genID=shift;
	my $refTXT=shift;
	my $refBGC=shift;
	$genID=~s/\|/\./;
	my $io = Bio::SeqIO->new(-format => "genbank", -file => ">$outname/GBK/$genID.gbk" );
	my $originalcontig="Unknown";
	if(-e $refTXT->{$genID}[0]){$originalcontig=$refTXT->{$genID}[0];}
	# create a simple Sequence object
	my $seq_obj = Bio::Seq->new(-seq => "aaaaaaa", -display_id => "$originalcontig");
                                    # Can also pass classification
                                    # array to new as below
    	my @classification=($genomeId);
	my   $species = Bio::Species->new(-classification => [@classification]);
	$seq_obj->species($species);

	foreach my $gen(@{ $refBGC }){
		#print "$gen\n";
		#print "$feature\t";
		my $contig=$refTXT->{$gen}[0];
		my $start=$refTXT->{$gen}[1];
		my $end=$refTXT->{$gen}[2];
		my $strand=$refTXT->{$gen}[3];
			if($strand eq '+'){$strand=1;}elsif($strand eq '-'){$strand='-1';}
		my $translation=$refTXT->{$gen}[5];
		my $product=$refTXT->{$gen}[4];
		# create the feature with some data, evidence and a note
		my $feat = new Bio::SeqFeature::Generic(-start  => $start,-end => $end,-strand => $strand, 
		-primary_tag => 'CDS',-tag => {organism=>"homo sapiens",contig=>"$contig",translation => "$translation" , product=>"$product", protein_id=>"$gen" });

		# then add the feature we've created to the sequence
		$seq_obj->add_SeqFeature($feat);
		}
	$io->write_seq($seq_obj);
	########## Reading whole fiile
	}
#_____________________________________________
                            
sub readingTxtFile{
	my $file=shift;
	my $HASH=shift;
	open (FILE, "$genomes_dir/GENOMES/$file.txt") or die "Couldnt open $file \n$!";
		foreach my $line (<FILE>) {
		chomp $line;	 
		my @st=split(/\t/,$line);
		$st[1]=~/\.peg\.(\d*)/;
		my $key=$file."_".$1;
		$HASH->{$key}=[$st[0],$st[4],$st[5],$st[6],$st[7],$st[12]];
#		print "#$st[1]#$HASH->{$st[1]}=($st[0],$st[5],$st[6],$st[7],$st[8],$st[12])\n";
#		my $pause=<STDIN>;
		close FILE;
		}
}
###########3 Reading whole file and in a HASH
#my $pause=<STDIN>;
################3 Subs 
sub fillinIdsArray{
	my $genId=shift;
	my $genomeId=shift;
	my @BGC;
	push(@BGC, $genId);
	for (my $i=1;$i<=10;$i++){
		my $genNumR=$genNumber+$i;
		my $genNumL=$genNumber-$i;
		my $idR="$genomeId\_$genNumR";
		push (@BGC,$idR);
		if($genNumL>0){
			my $idL="$genomeId\_$genNumL";
			push(@BGC,$idL);
			}
		}
	return @BGC;
}
