#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
no warnings 'experimental::smartmatch';

###

my $name="CORASON";                       ##Name of the group (Taxa, gender etc)
my $infile=$name;
my $NUM2=$ARGV[0];
my $list=$ARGV[1];
my $outname=$ARGV[2];

my $Working_dir="$outname/$infile";
print "\n $Working_dir \n";

if (-e "$outname/$infile/ALIGNMENTS_GB/") {system "rm -r $outname/$infile/ALIGNMENTS_GB/";}
system "mkdir $outname/$infile/ALIGNMENTS_GB/";

my $TOTAL=`wc -l < $outname/$infile/lista.ORTHOall`;

my @lista0=split(",",$list); ## MINI genomes list
my @sorted_clust = sort @lista0; ## Sorted MINI genomes list

for(my $gen=1;$gen<=$TOTAL;$gen++){
	print "\n&align $gen,$NUM2,$Working_dir,@sorted_clust\n";  ## Each gene will be aligned
	&align($gen,$NUM2,$Working_dir,@sorted_clust);  ## Each gene will be aligned
	}

system("mkdir $outname/$infile/CONCATENADOS");

print "\nGblocks and muscle have finished\n";
############################################################################################ 
####### subs
###############################################################################################

sub align{
	#	my $org
	#print "#$_[0]#";
	my $gen=shift;
	my $num=shift;
	my $Working_dir=shift;
	my @sorted_clusters=@_;

	system "muscle -in $Working_dir/FASTAINTER/$gen.interFastatodos -out $Working_dir/ALIGNMENTS_GB/$gen.muscle.pir -fasta -quiet -group";

#	print "muscle -in $Working_dir/FASTAINTER/$gen.interFastatodos -out $Working_dir/ALIGNMENTS_GB/$gen.muscle.pir -fasta -quiet -group";
	my $nombre="$Working_dir/ALIGNMENTS_GB/$gen.muscle.pir";
	open(FILE2,$nombre)or die "Couldnt open $nombre $!\n";
	#print("Se abrio el archivo $nombre\n");
	my @content=<FILE2>;
	my $headerFasta;
	my $clust;
	my %hashFastaH;

	foreach my $line (@content){
		#print" $line";
		if($line =~ />/){
                                chomp $line;
                                $headerFasta=$line;
                                $clust=$line;
				chomp $clust;
                        	$clust=~s/>fig\|*.*.peg.*\|//g; #Obtengo el indicador del cluster
                                $hashFastaH{$clust}=$headerFasta."\n";;
                        }
                        else{
                               # $line =~ s/\*//g;
				if(! -exists $hashFastaH{$clust}){$hashFastaH{$clust}="";}
			#	push(@sorted_clusters,$clust);
                                $hashFastaH{$clust}=$hashFastaH{$clust}.$line;
                                #print"$headerFasta => $hashFastaH{$headerFasta}\n";

                        }


	}
	
	open ORDEN,">$Working_dir/ALIGNMENTS_GB/$gen.orden.muscle" or die $!;

	 for (my $i=0;$i<$num;$i++){
#		print "pause\n" ;my $pause=<STDIN>;
         	#print("KEY:#$i# $sorted_clust[$i]  VALUE:$hashFastaH{$sorted_clust[$i]} \n");
#		if ($sorted_clust[$i]~~@lista0){
		print ORDEN "$hashFastaH{$sorted_clust[$i]}";
#		}
	}
	close ORDEN;
	#print @content;  ### Anaaa que eran las opciones del Gblocks??
	system "Gblocks $Working_dir/ALIGNMENTS_GB/$gen.orden.muscle -b4=5 -b5=n -b3=5";
	system("rm $Working_dir/ALIGNMENTS_GB/$gen.orden.muscle-gb.htm");
	close(FILE2);
}
############################################
	
