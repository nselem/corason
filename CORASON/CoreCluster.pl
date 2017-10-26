#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
use Getopt::Long 'HelpMessage';
no warnings 'experimental::smartmatch';
######################################################################
###This is the main script to run the ortho-group tools
######################################################################

=head1 NAME

Corecluster - get license texts at the command line!

=head1 SYNOPSIS

  --list,-l     Holder name (required)
  --num,-n       License year (defaults to current year)
  --help,-h       Print this help

=head1 VERSION

0.01

=cut

#print "This script will help you to find a core between genomes\n";
#print "How many genomes would you like to process?\n";

##################################################################
######## Subs on this file #######################################
sub cleanFiles;
sub specialCluster;
sub printVariables;
sub getDrawInputs;

##################################################################
############# Input variables

GetOptions(
        'verbose' => \my $verbose,
        'queryfile=s' => \my $queries,
        'special_org=i' => \my $special_org,
        'e_value=f'=> \(my $e_value=0.000001), 		# E value. Minimal for a gene to be considered a hit.
        'bitscore=i'=>\(my $bitscore=0),  		## Revisar el archivo .BLAST.pre para tener idea de este parámetro.
        'cluster_radio=i'=>\(my $cluster_radio=10), 	#number of genes in the neighborhood to be analized
        'e_cluster=f'=>\(my $e_cluster=0.001), #Query search e-value for homologies from reference cluster, values above this will be colored
        'e_core=f'=>\(my $e_core=0.001) ,  
        'list=s'=>\my $lista , ##Wich genomes would you process in case you might, otherwise left empty for whole DB search
        'rescale=i'=>\(my $rescale = 85000) ,
        'num=i'=>\my $num ,  #the number of genomes to be analized in case you used the option $LIST, comment if $LIST is empty
        'rast_ids=s' => \my $rast_ids,
	'antismash=s'=> \my $antismash,
	'help'     =>   sub { HelpMessage(0) },
        ) or HelpMessage(1);

die "$0 requires a query (--query\nfor help type:\ncorason.pl -h" unless $queries;  ## A genome list is mandatory
die "$0 requires the list argument (--list\nfor help type:\ncorason.pl -h" unless $lista;  ## A genome list is mandatory
die "$0 requires the rast_ids file (--rast_ids\nfor help type:\ncorason.pl -h" unless $rast_ids;  ## A genome names list is mandatory
die "$0 requires the special_org argument (--special_org\nfor help type:\ncorason.pl -h" unless $special_org;  ## A genome names list is mandatory

my $dir=&Cwd::cwd();            ##The path of your directory
my $name=pop @{[split m|/|, $dir]};             ##The path of your directory
my $blast="$name.blast";

printVariables($verbose);

#####################################################################
########## Main ######################################################

my @LISTA=split(",",$lista);
my $outname=$queries;
$outname=~s/\.query//;
if(!-e $outname) {system("mkdir $outname");}
if ($verbose ){print "Your courrent directory: $name\n";}

my $report="";
if (-e "$outname/$outname\_Report"){`rm $outname/$outname\_Report`;}
$report=$report."Queries $queries\tSpecial Organism $special_org\te_value $e_value\tbitscore $bitscore\tcluster radio $cluster_radio\te_core $e_core\trescale $rescale\tlist $lista\tnumber $num\tname folder $name\tdir $dir\tblast $blast\t";
my $INPUTS="";
my $orderFile="";

#_________  Query blast ________________________________________________________________________________
	print "\nSearching sequences from query (1_Context_text.pl)\n";
my $NUM = `wc -l < $rast_ids`;
	if ($NUM == $num){
		## All genomes will be procesed!!!!!!!!!!!!!!!!!
		system("1_Context_text.pl -q $queries -s $special_org -e_value $e_value -b $bitscore -c $cluster_radio -e_cluster $e_cluster -r $rescale -l $lista -n $num -rast_ids $rast_ids -type  prots -makedb -antismash $antismash");
                }
        else {
                print "\nSearching on clusters in reduced list: $lista\n";        
		system("1_Context_text.pl -q $queries -s $special_org -e_value $e_value -b $bitscore -c $cluster_radio -e_cluster $e_cluster -r $rescale -l $lista -n $num -rast_ids $rast_ids -type prots -makedb -antismash $antismash");
               }
	print "Sequences search finished\n\n";
#___________________ end Query blast ________________________________________________________________________

print "Analising cluster with hits according to the query sequence\n\n";
	my $new_data=`ReadingInputs.pl $outname`; 
	#exit;
	my @st=split(/\t/,$new_data);
($num,$lista)=split(/\t/,$new_data);
#$num=$st[0]; 
#$lista=$st[1];
	if ($verbose) {print "\n$num clusters found. Ids: $lista\n\n";}
	my $NumClust= `ls $outname/*.input2|wc -l`;
	chomp $NumClust;
	#$NumClust=~s/\r//;
	print "There are $NumClust similar clusters\n"; 
	$report=$report. "\n\nThere are $NumClust similar clusters\n"; 
#__________________________________________________________________________________________________________
print "Creating query hits tree, without considering the core-clusters\n";
	`cat $outname/*.input2> $outname/PrincipalHits`;

        print "\nAligning Sequences \n";
        system "muscle -in $outname/PrincipalHits -out $outname/PrincipalHits.muscle -fasta -quiet -group";
        print "\nShaving alignments with Gblocks\n";
        system "Gblocks $outname/PrincipalHits.muscle -b4=5 -b5=n -b3=5";
        system("RenamePrincipalHits.pl $outname PrincipalHits.muscle-gb $rast_ids");
	system "FastTree $outname/RightNamesPrincipalHits.txt > $outname/$outname\_PrincipalHits.tre";
	system("nw_topology -b -IL $outname/$outname\_PrincipalHits.tre | nw_display -b 'opacity:0' -v 40 -s - >$outname/$outname\_tree.svg");
	system "nw_labels -I $outname/$outname\_PrincipalHits.tre>$outname/PrincipalHits.order";
	$orderFile="$outname/PrincipalHits.order";
	if(! -e "$outname/PrincipalHits.order"){
	##last hope, if the enzyme tree cant be produced this may be due tu the shave
	## So we will try the tree without shave the enzyme 
        system("RenamePrincipalHits.pl $outname PrincipalHits.muscle $rast_ids");
	system "FastTree $outname/RightNamesPrincipalHits_Unshaved.txt > $outname/$outname\_Unshaved.tre";
	system("nw_topology -b -IL $outname/$outname\_Unshaved.tre | nw_display -b 'opacity:0' -v 40 -s - >$outname/$outname\_tree.svg");
	system "nw_labels -I $outname/$outname\_Unshaved.tre>$outname/PrincipalHitsUnshaved.order";
	$orderFile="$outname/PrincipalHitsUnshaved.order";
	}

#______________________________________________________________________________________________________________

	print "Searching genetic core on selected clusters\n";
	print"2_OrthoGroups.pl -e_core $e_core -list $lista -num $num -rast_ids $rast_ids -outname $outname\n";
	#print "Enter to continue\n";
	#my $pause=<STDIN>;
	system("2_OrthoGroups.pl -e_core $e_core -list $lista -num $num -rast_ids $rast_ids -outname $outname");
	print "Core finished!\n\n";
	my $boolCore= `wc -l <$outname/Core`;
	chomp $boolCore;
	#print "Elements on core: $boolCore!\n";
#____________________________________________________________________________________________________________
if ($boolCore>1){
	print "There is a core with at least two genes on this cluster\n";
	$report=$report."\nThere is a core composed by $boolCore orhtolog on this cluster\n";
	$report=$report. "Enzyme functions on reference organisms are given by:\n";
	## Obteniendo el cluster del organismo de referencia mas parecido al query
	# Abrimos los input files de ese organismo y tomamos el de mejor score
	my $specialCluster=specialCluster($special_org);
	print "Best cluster $specialCluster\n";
	print "Best cluster $outname\n";
	$specialCluster=~s/$outname\///;
	my $functions=`cut -f1,2 $outname/CORASON/FUNCTION/$specialCluster.core.function `;
	#my $pause=<STDIN>;
	
	print "cut -f1,2 $outname/CORASON/FUNCTION/$specialCluster.core.function ";
	# print "cut -f1,2 $name/FUNCTION/$specialCluster.core.function ";
	#	print "Function $functions#\n";
	$report=$report."\n".$functions;

	print "Aligning...\n";
	system ("multiAlign_gb.pl $num $lista $outname");
	print "Sequences were aligned\n\n";
	print "Creating aminoacid core cluster matrix..\n";
	system("ChangeName.pl $outname");
	system("EliminadorLineas.pl $outname");
	system("Concatenador.pl $outname");
	system("Rename_Ids_Star_Tree.pl $rast_ids $outname");
	my $line =`perl -ne \'print if \$\. == 2\' $outname/RightNames.txt `;
	#print "`perl -ne 'print if \$\. == 2' RightNames.txt `";
	#print "Line $line\n";
	my $len = map $_, $line =~ /(.)/gs;
	$len--;
	$report=$report."\nAminoacid array size = $len \n\n";
	print "Formating matrix..\n";
	system "FastTree $outname/RightNames.txt > $outname/$outname\_BGC.tre";

#	system "mv $outname/BGC_TREE.tre $outname/$outname\_BGC.tre";
	system("nw_topology -b -IL $outname/$outname\_BGC.tre | nw_display -b 'opacity:0' -v 40 -s - >$outname/$outname\_tree.svg");
	system "nw_labels -I $outname/$outname\_BGC.tre>$outname/$outname\_BGC_TREE.order";
	$orderFile="$outname/$outname\_BGC_TREE.order";
	print "I will draw SVG clusters with concatenated tree order\n";
	$INPUTS=getDrawInputs($orderFile);
	}
	else {
		if(-s $orderFile){
			### If there is no core, then sort according to principal hits
			$report=$report. "The only gen on common on every cluster is the main hit\n";
			print "I will draw SVG clusters with the single hits order\n";
			$report=$report. "I will draw with the single hits order\n";
			$INPUTS=getDrawInputs($orderFile);
			my $line =`perl -ne \'print if \$\. == 2\' $outname/PrincipalHits `;
			my $len = map $_, $line =~ /(.)/gs;
			$len--;
			$report=$report."\nAminoacid array size = $len \n\n";
			}
		}
	if(!-s $orderFile){
		print "$outname outname \n\n";
		### If there is no core, then sort according to principal hits
		$report=$report. "Sequences did not align. nevertheless you can still see homologous clusters\n";
		print "Sequences didnt align, I will draw SVG clusters with the single hits blast order\n";
		$report=$report. "I will sort draws with the single hits blast order\n";
		$INPUTS=blast_sort($outname);
	}

#_____________________________________________________________________________________________

print "Now SVG file will be generated with inputs: $INPUTS\n\n";
#	print "3_Draw.pl $rescale $INPUTS $outname";
	system("3_Draw.pl $rescale $INPUTS $outname");

print "SVG  file generated\n\n";
`mv $outname/Contextos.svg $outname/$outname\.svg`;

open (REPORTE, ">$outname/$outname\_Report") or die "Couldn't open reportfile $!";
print REPORTE $report;
close REPORTE;

print "Cleaning temporary files\n";
cleanFiles($outname);

print "Done\n";
print "Have a nice day\n\n";
exit;
######################################################################
######################################################################
###   Sub  Rutinas (llamadas a los distintos pasos del script
#######################################################################
#######################################################################

sub blast_sort{
my $name=shift;
my %PRE_SORTED;
my @CLUSTERS=qx/ls $name\/*.input/;
foreach my $id(@CLUSTERS){
chomp $id;
# print "Id on blast sort $id\n";
# print "entre to continue \n";
# my $pause=<STDIN>;
my @st=split(/[\/_\.]/,$id);
# print "0 $st[0] 1:$st[1], 2:$st[2],3$st[3]\n";
my $newId="peg.".$st[2]."|".$st[1];
# system (" echo grep '$newId' $name/$name.BLAST");
my $num = `grep -n -m1 '$newId' $name/$name.BLAST|cut -d':' -f1`;
chomp $num;
if($num){
$id=~s/$name\///;
$PRE_SORTED{$num}=$id;
# print"Id $id -> $num\n";
}
}
my $INPUTS;
foreach my $num(sort{$a<=>$b} keys %PRE_SORTED) {
$INPUTS=$INPUTS.$PRE_SORTED{$num}.",";
# print "$num -> $PRE_SORTED{$num}\n";
}
#print "####################################3\n#";
chop $INPUTS;
#print "INPUTS= $INPUTS\n";
return $INPUTS;
}

sub specialCluster{
	my $special_org=shift;
	my @CLUSTERS=qx/ls $outname\/$special_org\_*.input/;
	my $specialCluster="";
	my $score=0;
	foreach my $cluster (@CLUSTERS){
		chomp $cluster;
		#print "I will open #$cluster#\n";
		open (FILE, $cluster) or die "Couldn't open $outname/$cluster\n"; 
		my $firstLine = <FILE>; 
		chomp $firstLine;
		close FILE;
		#print "Primera linea $firstLine\n";
		my @sp=split(/\t/,$firstLine);
			#print "Score $sp[7]\n";
			#print "6 $sp[6] 7 $sp[7]\n";
			if ($score<=$sp[7]){
				$specialCluster=$cluster;
				}
		}
	$specialCluster=~s/\.input//;
	return $specialCluster;
}
#__________________________________________________________________________
sub cleanFiles{
    #    `rm *.lista`;
        `rm $outname/lista.*`;
        #`rm $outname/*.input`;
        if (-e "$outname/*.input2"){`rm $outname/*.input2`;}
        `rm $outname/*.input2`;
        `rm $outname/Core`;
        `rm $outname/PrincipalHits`;
        `rm $outname/PrincipalHits.muscle`;
        `rm $outname/PrincipalHits.muscle-gb`;
        `rm $outname/PrincipalHits.muscle-gb.htm`;
        `rm $outname/*.order`;
        `rm $outname/Core0`;
        `rm -r $outname/OUTSTAR`;
        `rm -r $outname/MINI`;
        `rm -r $outname/*.faa`;
        `rm -r $outname/*.blast`;
        `rm -r $outname/*.txt`;
	`chmod +w $outname $outname/*.*`
        }
#_____________________________________________________________________________________

sub getDrawInputs{
	my $file=shift;
	my $INPUTS="";
	open (NAMES,$file) or die "Couldnt open $orderFile $!";

	foreach my $line (<NAMES>){
		chomp $line;
		my @spt=split(/_org_|_peg_/,$line);
		$INPUTS.=$spt[2]."_".$spt[1]."\.input,";
		#print "$INPUTS\n";
		}
		my $INPUT=chop($INPUTS);
		#print "!$INPUTS!\n";
	#obtener el numero de organismos
	#pasarselo al script 2.Draw.pl
	return $INPUTS;
	}
#_________________________________________________________________________________

sub printVariables{
	if ($verbose){
		print "Queries $queries\n";
		print "Special Organism $special_org\n";
		print "e_value $e_value\n";
		print "bitscore $bitscore\n";
		print "cluster radio $cluster_radio \n";
		print "e_core $e_core\n ";
		print "rescale $rescale \n";
		print "list $lista \n";
		print "number $num \n";
		print "name folder $name\n";
		print "dir $dir \n";
		print "blast $blast\n";
		print  "verbose  $verbose\n";
		}
	}
######################################################################
