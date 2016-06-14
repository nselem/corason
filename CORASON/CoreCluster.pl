#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
use Getopt::Long 'HelpMessage';

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
	'help'     =>   sub { HelpMessage(0) },
        ) or HelpMessage(1);

die "$0 requires the list argument (--list\n" unless $lista;  ## A genome list is mandatory
die "$0 requires the rast_ids argument (--list\n" unless $rast_ids;  ## A genome names list is mandatory
die "$0 requires the special_org argument (--list\n" unless $special_org;  ## A genome names list is mandatory

my $dir=&Cwd::cwd();            ##The path of your directory
my $name=pop @{[split m|/|, $dir]};             ##The path of your directory
my $blast="$name.blast";

printVariables($verbose);

#####################################################################
########## Main ######################################################

my @LISTA=split(",",$lista);
my $outname=$queries;
$outname=~s/\.query//;
if ($verbose ){print "Your courrent directory: $name\n";}

my $report="";
if (-e "$outname\_Report"){`rm $outname\_Report`;}
$report=$report."Queries $queries\tSpecial Organism $special_org\te_value $e_value\tbitscore $bitscore\tcluster radio $cluster_radio\te_core $e_core\trescale $rescale\tlist $lista\tnumber $num\tname folder $name\tdir $dir\tblast $blast\t";


#_________  Query blast ________________________________________________________________________________
	print "Searching sequences from query\n\n";
	if ($lista eq ""){
		## AQUI QUE PASA CON LOS COLORES!!!!!!!!!!!!!!!!!
		system("1_Context_text.pl -q $queries -s $special_org -e_value $e_value -b $bitscore -c $cluster_radio -e_cluster $e_cluster -r $rescale -l $lista -n $num -rast_ids $rast_ids -type  prots ");
                }
        else {
                print "Searching on reduced database (only in clusters on $lista)\n";        
		system("1_Context_text.pl -q $queries -s $special_org -e_value $e_value -b $bitscore -c $cluster_radio -e_cluster $e_cluster -r $rescale -l $lista -n $num -rast_ids $rast_ids -type prots -makedb prots");
               }
	print "Sequences search finished\n\n";
#___________________ end Query blast ________________________________________________________________________


print "Analising cluster with hits according to the query sequence\n\n";
	my $new_data=`ReadingInputs.pl`; 
	my @st=split(/\t/,$new_data);
($num,$lista)=split(/\t/,$new_data);
#$num=$st[0]; 
#$lista=$st[1];
	if ($verbose) {print "\n$num clusters found. Ids: $lista\n\n";}
	my $NumClust= `ls *.input2|wc -l`;
	chomp $NumClust;
	#$NumClust=~s/\r//;
	print "There are $NumClust organisms with similar clusters\n"; 
	$report=$report. "\n\nThere are $NumClust organisms with similar clustersi\n"; 
#__________________________________________________________________________________________________________
print "Creando arbol de Hits del query, sin considerar los clusters\n";
	`cat *.input2> PrincipalHits`;

        print "\nAligning Sequences \n";
        system "muscle -in PrincipalHits -out PrincipalHits.muscle -fasta -quiet -group";

        print "\nShaving alignments with Gblocks\n";
        system "Gblocks PrincipalHits.muscle -b4=5 -b5=n -b3=5";
        system("RenamePrincipalHits.pl PrincipalHits $rast_ids");

        print "\Saving as Stockolm format\n";
	system(" converter.pl RightNamesPrincipalHits.txt ");
	print ("constructing a tree with quicktree with a 100 times bootstrap\n");
	system "quicktree -i a -o t -b 100 RightNamesPrincipalHits.stockholm > PrincipalHits_TREE.tre";
	system "mv PrincipalHits_TREE.tre $outname\_PrincipalHits.tre";
        print ("Getting Newick labels\n");
	system "nw_labels -I $outname\_PrincipalHits.tre>PrincipalHits.order";
	my $INPUTS=""; ## Orgs sorted according to a tree (Will be used on the Context draw)
	my $orderFile="PrincipalHits.order";
#______________________________________________________________________________________________________________
	print "Searching genetic core on selected clusters\n";
	system("2_OrthoGroups.pl -e_core $e_core -list $lista -num $num -rast_ids $rast_ids ");
	print "Core finished!\n\n";
	my $boolCore= `wc -l Core`;
	chomp $boolCore;
	$boolCore=~s/[^0-9]//g;
	$boolCore=int($boolCore);
	print "Elements on core: $boolCore!\n";
#____________________________________________________________________________________________________________
if ($boolCore>1){
	print "There is a core with at least to genes on this cluster\n";
	$report=$report."\nThere is a core composed by $boolCore orhtolog on this cluster\n";
	$report=$report. "Enzyme functions on reference organisms are given by:\n";
	## Obteniendo el cluster del organismo de referenecia mas parecido al query
	# Abrimos los input files de ese organismo y tomamos el de mejor score	
	my $specialCluster=specialCluster($special_org);
	print "Mejor cluster $specialCluster\n";
       	my $functions=`cut -f1,2 $name/FUNCTION/$specialCluster.core.function `;
#       	print "cut -f1,2 $name/FUNCTION/$specialCluster.core.function ";
#	print "Function $functions#\n";
	$report=$report."\n".$functions;
	print "Aligning...\n";
	system ("multiAlign_gb.pl $num $lista");
	print "Sequences were aligned\n\n";

	print "Creating matrix..\n";
	system("ChangeName.pl");
	system("EliminadorLineas.pl");

	system("Concatenador.pl");
	system("Rename_Ids_Star_Tree.pl");
	my $line =`perl -ne \'print if \$\. == 2\' RightNames.txt `;
	#print "`perl -ne 'print if \$\. == 2' RightNames.txt `";
	#print "Line $line\n";
 	my $len = map $_, $line =~ /(.)/gs;
	$len--;
	$report=$report."\nAminoacid array size = $len \n\n";
	print "Formating matrix..\n";
	system ("converter.pl RightNames.txt");

	print "constructing a tree with quicktree with a 100 times bootstrap";
	system "quicktree -i a -o t -b 100 RightNames.stockholm > BGC_TREE.tre";
	system "mv BGC_TREE.tre $outname\_BGC.tre";
	system "nw_labels -I $outname\_BGC.tre>$outname\_BGC_TREE.order";

 	$orderFile="$outname\_BGC_TREE.order";
	print "I will draw with concatenated tree order\n";
	$INPUTS=getDrawInputs($orderFile);
	}
	else{  ### If there is no core, then sort according to principal hits
		$report=$report. "The only gen on common on every cluster is the main hit\n";
		if (-e $orderFile){
			print "I will draw with the single hits order\n";
			$report=$report. "I will draw with the single hits order\n";
			$INPUTS=getDrawInputs($orderFile);
        		}
		my $line =`perl -ne \'print if \$\. == 2\' PrincipalHits `;
 		my $len = map $_, $line =~ /(.)/gs;
		$len--;
		$report=$report."\nAminoacid array size = $len \n\n";
        	}
#_____________________________________________________________________________________________

print "Now SVG file will be generated with inputs: $INPUTS\n\n";
	system("3_Draw.pl $rescale $INPUTS");

print "SVG  file generated\n\n";
`mv Contextos.svg $outname\.svg`;

open (REPORTE, ">$outname\_Report") or die "Couldn't open reportfile $!";
print REPORTE $report;
close REPORTE;

print "Cleaning temporary files\n";
cleanFiles();

print "Done\n";
print "Have a nice day\n\n";
exit;
######################################################################
######################################################################
###   Sub  Rutinas (llamadas a los distintos pasos del script
#######################################################################
#######################################################################
sub specialCluster{
	my $special_org=shift;
	my @CLUSTERS=qx/ls $special_org\_*.input/;
	my $specialCluster="";
	my $score=0;
	foreach my $cluster (@CLUSTERS){
		chomp $cluster;
		#print "I will open #$cluster#\n";
		open (FILE, $cluster) or die "Couldn't open $cluster\n"; 
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
        `rm lista.*`;
        `rm *.input`;
        if (-e "*.input2"){`rm *.input2`;}
        `rm *.input2`;
        `rm Core`;
        `rm PrincipalHits`;
        `rm PrincipalHits.muscle`;
        `rm PrincipalHits.muscle-gb`;
        `rm PrincipalHits.muscle-gb.htm`;
        `rm *.order`;
        `rm Core0`;
        `rm -r OUTSTAR`;
        `rm -r MINI`;
        `rm -r *.stockholm`;
        `rm -r *.faa`;
        `rm -r *.blast`;
        `rm -r *.txt`;
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
