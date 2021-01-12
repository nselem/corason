#!/usr/bin/perl 
use lib '/usr/local/lib/perl5/site_perl/5.20.3';
use Cwd qw(cwd);

## I want to extract CDS entrys and ids from a geneBankFile
## coordinates from each CDS and direction
## this file input is an NCBI file, a name of the file and the proposed rastid and 
## output is a fasta file with proposed rast id and a txt wit the same id.
## this scrits numbers consecutively each feature.
### 
#perl gbkToRast.pl dir InputGBK File 6666666.285897.gbk RastNo 100003 Acc MNHQ01000080.1 SpActinobacteria sp MNHQ01 MNHQ01

use Bio::SeqIO;
my $dir=$ARGV[0];
my $file=$ARGV[1];
my $number=$ARGV[2];
my $dir_scripts=$ARGV[3];
my $accession="accession";
my $species_name="species";
my $outdir="/home/output";
if($dir_scripts eq "CORASON"){
        $outdir=cwd;
        }

#if (-e "CORASON_GENOMES"){system("rm -r CORASON_GENOMES");  }
#system("mkdir CORASON_GENOMES");

$seqio_obj = Bio::SeqIO->new(-file => "$dir/$file",  -format => "genbank" );
my $out= Bio::SeqIO->new(-file=> ">$outdir/GENOMES/$number\.faa",-format=> 'Fasta');
my $txt=open(FILE,">$outdir/GENOMES/$number\.txt") or die $!;

#print FILE "contig_id\tfeature_id\ttype\tlocation\tstart\tstop\tstrand\tfunction\tspecies\tfigfam\tevidence_codes\tnucleotide_sequence\taa_sequence\n";
print FILE "contig_id\tfeature_id\ttype\tlocation\tstart\tstop\tstrand\tfunction\tlocus_tag\tfigfam\tspecies\tnucleotide_sequence\tamino_acid\tsequence_accession\n";
#contig_id LOCUS  falta
# feature_id rast YA
#\ttype\tlocation\tstart\tstop\tstrand\t YA
# function \product
# ialiases ACCESSION  YA
#\tfigfam\tspecies\tnucleotide_sequence\t YA
# Sequence accesion sequence_accession\n"; YA
my $cont=1;

##leer todas las secuencias oe file by seq obj
while (my $seq_object = $seqio_obj->next_seq ){
            $accession= $seq_object->accession . "\n"; ##Getting accesion
            my $LOCUS= $seq_object->display_id;# . "\n"; ##Getting accesion
            #print" $LOCUS\n"; ##Getting accesion
	    if ($seq_object->species){$species= $seq_object->species->binomial();};

	    for my $feat_object ($seq_object->get_SeqFeatures) {
		if($pecies ne "species"){
			### geting org name 
 	      		if($feat_object->primary_tag eq "source"){
                   	for my $tag ($feat_object->get_all_tags) {
        			if($tag eq "organism"){
 					for my $value ($feat_object->get_tag_values($tag)) {
							$species_name=$value;
							#print"$species\n";				
                                                        next;
                                                        }
						next;
                                  	        }
					next;
				  	}
     			} ##end org namei
		}
	######### gettting sequences 
    	if ($feat_object->primary_tag eq "CDS") {
		my $start="s"; my $end="e"; my $dir="dir" ;my $proti="p"; my $val="acc"; my $product="func";
        	if ( $feat_object->has_tag('translation') ) {
                	for my $protein ($feat_object->get_tag_values('translation')) {
		#print "Hey I have  trans\n";
				$protein=~s/\*//g;
#                       	print ">$val\n$prot\n";
				$prot=$protein;
                        		$start = $feat_object->location->start;
	                        	$dir = $feat_object->strand;
	                        	$end = $feat_object->location->end;
	                        	if($dir == 1) {$dir="+";}elsif($dir== -1){$dir="-";my $temp=$start; $start=$end;$end=$temp;}

#				print FILE "contig_id\tfeature_id\ttype\tObject_accesion\tstart\tstop\tstrand\tfunction\tlocus_tag\tfigfam\tspecies\tnucleotide_sequence\tsequence_accession\n";
					chomp $accession;
       		 			}
				
		if ($feat_object->has_tag('locus_tag')){
			 for my $locus_tag ($feat_object->get_tag_values('locus_tag')){
							$val=$locus_tag;} }
		if ($feat_object->has_tag('product')){ 
			 for my $func ($feat_object->get_tag_values('product')){
							$product=$func; }}

				if(length($prot)>0){
                        	print FILE "$LOCUS\tfig|666666.$number.peg.$cont\ttype\tlocation\t$start\t$end\t$dir\t$product\t$accession\tfigfam\t$species_name\tnuc\t$prot\t$val\n";
              			my $seq = Bio::Seq->new(-seq => $prot, -display_id => "fig|666666.$number.peg.$cont");
                        	#my $pause=<STDIN>;
				$out->write_seq($seq);	
                        	$cont++;
				}
                        }
	}              
}
                ## aumentar contador
                #my $seq_object = $seqio_obj->next_seq;
        #       my $org="";
        #       my $accesion;


        #       if (!$org){
        #               for my $feat_object ($seq_object->get_SeqFeatures) {
#                               }
#                       }
#               chomp $org; chomp $accesion;

}
close FILE;

