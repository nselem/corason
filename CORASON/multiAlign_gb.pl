#!/usr/bin/perl
use strict;
use warnings;
use Cwd;

###
# Example 2 genomes 16 genes

my $dir2=&Cwd::cwd();
my $name=pop @{[split m|/|, $dir2]};                       ##Name of the group (Taxa, gender etc)
my $infile=$name;
my $NUM2=$ARGV[0];
my $list=$ARGV[1];

my $Working_dir="$dir2/$infile";

if (-e "$dir2/$infile/ALIGNMENTS_GB/") {system "rm -r $dir2/$infile/ALIGNMENTS_GB/";}
system "mkdir $dir2/$infile/ALIGNMENTS_GB/";

my $TOTAL=`wc -l < $dir2/$infile/lista.ORTHOall`;

my @lista0=split(",",$list); ## MINI genomes list
my @sorted_clust = sort @lista0; ## Sorted MINI genomes list

for(my $gen=1;$gen<=$TOTAL;$gen++){
	&align($gen,$NUM2,$Working_dir,@sorted_clust);  ## Each gene will be aligned
	}

system("mkdir $dir2/$infile/CONCATENADOS");

print "Gblocks and muscle have finished\n";
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
	system("rm $dir2/$infile/ALIGNMENTS_GB/$gen.orden.muscle-gb.htm");
	close(FILE2);
}
############################################
	
