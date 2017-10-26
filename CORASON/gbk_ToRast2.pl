#!/bin/perl 
## I want to extract CDS entrys and ids from a geneBankFile
## coordinates from each CDS and direction
## this file input is an NCBI file, a name of the file and the proposed rastid and 
## output is a fasta file with proposed rast id and a txt wit the same id.
## this scrits numbers consecutively each feature.

use Bio::SeqIO;
my $file=$ARGV[0];
my $number=$ARGV[1];
my $name=$ARGV[2];
my $compound=$ARGV[3];

$seqio_obj = Bio::SeqIO->new(-file => "$file",  -format => "genbank" );
my $out= Bio::SeqIO->new(-file=> ">BIG_OUTPUT/$compound/GENOMES/$number\.faa",-format=> 'Fasta');
my $txt=open(FILE,">BIG_OUTPUT/$compound/GENOMES/$number\.txt") or die $!;
my $seq_object = $seqio_obj->next_seq;

print FILE "contig_id\tfeature_id\ttype\tlocation\tstart\tstop\tstrand\tfunction\taliases\tfigfam    
evidence_codes\tnucleotide_sequence\taa_sequence\n";

my $cont=1;
for my $feat_object ($seq_object->get_SeqFeatures) {
    if ($feat_object->primary_tag eq "CDS") {
        if ($feat_object->has_tag('locus_tag') and $feat_object->has_tag('translation') ) {
            for my $val ($feat_object->get_tag_values('locus_tag')) {
                for my $prot ($feat_object->get_tag_values('translation')) {
#                       print ">$val\n$prot\n";
                        my $start = $feat_object->location->start;
                        my $dir = $feat_object->strand;
                        if($dir == 1) {$dir="+";}elsif($dir== -1){$dir="-";}
                        my $end = $feat_object->location->end;
                        print FILE "$name\tfig|666666.$number.peg.$cont\ttype\tlocation\t$start\t$end\t$dir\tfunction\t$val\tfigfam\tevidence\tnuc\t
$prot\n";
              my $seq = Bio::Seq->new(-seq => $prot, -display_id => "fig|666666.$number.peg.$cont");
                        #my $pause=<STDIN>;
		$out->write_seq($seq);	


                        $cont++;
                        }
                }
        }
    }
}

close FILE;

