#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long 'HelpMessage';
use Cwd;
no warnings 'experimental::smartmatch';

=head1 NAME

1_Context_tex - get license texts at the command line!

=head1 SYNOPSIS

  --list,-l     Holder name (required)
  --num,-n       License year (defaults to current year)
  --help,-h       Print this help

=head1 VERSION

0.01

=cut

## Inputs genomes .faa .txt
#############################################################
#perl 1_Context_text.pl queryfile boolMakeblast type
## set boolMakeblast to 1 if no database has been created for each genome
## set boolMakeblast to 0 if there are already databases for each genome

#Gets BestHits de acuerdo acording to the e-value
# Writes gen Id, coordinatesand function
# Author nselem84@gmail.com

################################################################################################################
######  	Set variables 
	#the query

my $dir=&Cwd::cwd();            ##The path of your directory
my $name=pop @{[split m|/|, $dir]};             ##The path of your directory
my $genome_dir="GENOMES";

GetOptions(
        'verbose' => (\my $verbose),
        'queryfile=s' => \my $queries,
        'special_org=i' => \my $special_org,
        'e_value=f'=> \my $e_value,
        'bitscore=i'=>\my $bitscore,
        'num=i'=>\my $num,
        'makedb'=>\my $MakeDB,
        'cluster_radio=i'=>\my $cluster_radio,
        'e_cluster=f'=>\my $e_cluster,
        'list=s'=>\my $list ,
        'rast_ids=s' => \my $rast_ids,
        'type=s' => \my $type,
	 'help'     =>   sub { HelpMessage(0) },
        ) or HelpMessage(1);

die "$0 requires the list argument (--list\n" unless $list;  ## A genome list is mandatory
die "$0 requires the rast_ids argument (--rast_ids\n" unless $rast_ids;  ## A genome names list is mandatory

my $query_name=$queries;			
$query_name=~s/.query//; # $outname
system("cp $queries $query_name/$queries");
if ($verbose){print "Your special org is $special_org\n";}
my %query=ReadFile($queries);
my $DB="ProtDatabase";		##DataBAse Name
my @LISTA=split(",",$list);
my $eSeq=$e_value; 			## Evalue principal query

printVariables();
#______________________________________

###############################################################################################################
######### Searching homologous hits to query
################################################################################################################# 

				print "I will search homologous genes in organisms\n";
`mkdir $query_name/MINI`;
#print "Parameters\n";
if($MakeDB){
	$MakeDB=1;
	print "I will create a Database with selected genomes\n";
	$DB="$query_name\/temDatabase";
	}
else{
	$MakeDB=0;	
	print"I will use the full DB ProtDatabase\n";
	}


MakeBlast($query_name,$MakeDB,$type,$query_name,$eSeq,$DB,$bitscore,$num,$genome_dir,$rast_ids,@LISTA); 	
				## Search query by blast in all the other organisms
				## Save blast results on a $name file
my %Hits; 			
my %AllHits;
BestHits($query_name,$query_name,\%Hits,\%AllHits);
				## BestHits  ##Read Blast file created by MakeBlast sub whit at least $eSeq as evalue cutoff
				## Stores best hits on Hash Hits  BBBYYYY identity
				#refHits->{$name}{$org}=[$percent,$peg];
print "Looking for hits\n";
#		foreach my $key (keys %Hits){ print "$key -> $Hits{$key}\n"; }
		

my %ORGANISMS=readNames($rast_ids);


#my $PEG=$Hits{$name}{$special_org}[1];
my $PEG=$Hits{$query_name}{$special_org}[1];

if($verbose){print "$query_name, $special_org $PEG\n";}
				print "homologous gene search finished\n";

###########################################################################################################################
######### Get $special_org cluster
##########################################################################################################################
## organism peg
## Grep organism in txt file and get $gen number around
my $ClusterSize=$cluster_radio; ##Gen number around
my $eClust=$e_cluster;
my %CLUSTER;
				print "Searching for homologous gene in clusters \n";
#### 
my %CLUSTERcolor=BlastColor($query_name,$PEG,$special_org,$cluster_radio,$num,$eClust,$DB,$genome_dir,$rast_ids,\%CLUSTER,@LISTA);
#foreach my $peg (sort keys %CLUSTERcolor){
#	print "Peg $peg orgs $orgs";
#	foreach my $orgs (@{$CLUSTERcolor{$peg}}){
#		foreach my $color_percent(@{$CLUSTERCOLOR{$peg}[$orgs]}){
#			print "Color $color_percent\t";
#		}
#		print "\n";
#	}
#}
##print "Pause to look into blast\n";
##my $pause=<STDIN>;
				print "I have colored genes according to homology\n";		
## Color if pegi_orgj in Cluster{$peg} for some peg set colorNumber 
########################################################################################################################

print "Now I will produce the *.input file\n";
#print "Enter to continue\n";
#my $pause= <STDIN>;

for my $orgs (sort keys %{$AllHits{$query_name}}){
		foreach my $hit(@{$AllHits{$query_name}{$orgs}}){
			my @sp = split("\_",$hit);

			my $peg=$sp[0];
			my $percent=$sp[1];
		#	print "Org ¡$orgs! Hit ¡$peg! percent $percent\n";
		
			ContextArray($query_name,$orgs,$peg,$special_org,$percent,\%ORGANISMS,\%AllHits);
		}
}


#for my $orgs(keys %ORGANISMS){
#	if (!(-e "$orgs.input")){
#		open FILE, ">$orgs.input" or die "Could not create input file $orgs.input\n";
#		print FILE "0\t0\t-\t0\t$ORGANISMS{$orgs}\t0\t0\n";
#		close FILE;
#
#		open FILE2, ">MINI/$orgs.faa" or die "Could not create input file MINI/$orgs.faa\n";
#		close FILE2;
#		}
#}

if ($verbose){print "$query_name, $special_org $PEG\n";}
`rm $query_name/Cluster*.*.*`;
`rm $query_name/Cluster*.*`;
if($MakeDB==1){`rm $query_name/temDatabase.*`;}
#########################################################################################################################
##########################################################################################################################




############################################################################################################################
############################## Subs #######################################################################################
#____________________________________________________________________________________________
#########################################################################################################################
sub readNames{
	my $rast_ids=shift;
	open FILE,  "$rast_ids" or die "I can not open the input FILE $rast_ids\n";
	my %orgs;
	my $key="";
	my $count="1";
	while (my $line=<FILE>){
		chomp $line;
		$line=~s/\r//;
		my @sp=split("\t",$line);			
		my $org=$sp[0];
		$org=~s/\.faa//;
		$org=~s/\s*//;
		if ($verbose){print "I will use as query $org\n";}
		$orgs{$org}=$sp[2];
		$count++;
		}


	if ($verbose) {
		for my $keys (keys %orgs){
			print("¿$keys?:¡$orgs{$keys}!\n");
			}
		}
	close FILE;
	return %orgs;
	}

#____________________________________________________________________________________________
sub ContextArray{
	my $query_original=shift;
	my $orgs=shift;
	my $peg=shift;
	my $special_org=shift;
	my $percent0=shift;
	my $refORGANISMS=shift;
	my $refHits=shift;

	#if ($verbose) {print "org $orgs peg $peg\n";}
	open(FILE,">$query_original/$orgs\_$peg.input")or die "could not open $query_original/$orgs\_$peg.input file $!";
	open(FILE3,">$query_original/$orgs\_$peg.input2")or die "could not open $query_original/$orgs\_.$peg.input2 file $!";

	open(FILE2,">$query_original/MINI/$orgs\_$peg.faa")or die "could not open $query_original/MINI/$orgs\_$peg.faa file $!";

	my @CONTEXT;
	my ($hit0,$start0,$stop0,$dir0,$func0,$contig0,$amin0)=getInfo($peg,$orgs);
	$CONTEXT[0]=[$hit0,$start0,$stop0,$dir0,$func0];

	#if($verbose){
	#print "Context Arrays:hit $CONTEXT[0][0] start $CONTEXT[0][1] stop $CONTEXT[0][2] dir $CONTEXT[0][3] func $CONTEXT[0][4]\n\n";		}
	print FILE "$CONTEXT[0][1]\t$CONTEXT[0][2]\t$CONTEXT[0][3]\t1\t$refORGANISMS->{$orgs}\t$CONTEXT[0][4]\t$CONTEXT[0][0]\t$percent0\n";

	#print "Enter to continue\n";
	#my $pause=<STDIN>;
	#my $PreOrgNam=$refORGANISMS->{$orgs};
	#my @PreNames=split(" ",$PreOrgNam);
	#my $orgNam=$PreNames[0]."_".$PreNames[1];
	#my $orgNam=$PreOrgNam;
	#$orgNam=~s/ /_/g;
	my $genId=$hit0;
	$genId=~s/fig\|/_/g;
	my @spt=split(/\./,$genId);

	my $FinalName="peg_".$spt[$#spt]."_org".$orgs;
	$FinalName=~s/\./_/g;	$FinalName=~s/__/_/g;
	print FILE2 ">$hit0\n$amin0\n";

	print FILE3 ">$FinalName\n$amin0\n";
	close FILE3;

	my $count=1;	

	my $iniciar=0;
	if($peg-$ClusterSize>0){$iniciar=$peg-$ClusterSize;}	
	for (my $i=$iniciar;$i<$peg+$ClusterSize;$i++){
		if($i!=$peg){

			my ($hit,$start,$stop,$dir,$func,$contig,$amin)=getInfo($i,$orgs);
			if(!($hit eq "")){
				if($contig0 eq $contig){
					$CONTEXT[$count]=[$hit,$start,$stop,$dir,$func];

					#setColor
				        my($color,$percent)=setColor($i,$orgs);			
					#print "Peg $peg";
					#print "Color $color \n";
					#print "Percent $percent";
					#print "Orgs  $orgs  \n";
					#print "Hit $hit Start $start Stop $stop dir $dir Func $func  \n";
					#print "Hit $hit 1:$CONTEXT[$count][0]\n ";
					#print "1: $CONTEXT[$count][1] Start $start\n";
					#print "2: Stop $stop $CONTEXT[$count][2]\n";
					#print "dir $dir 3:$CONTEXT[$count][3]\n";
					#print "color $color\n";
					#print "Ref Organisms $refORGANISMS->{$orgs}\n";
					#print "Func $func 4:$CONTEXT[$count][4]\n";
					#print "Hit 0:$CONTEXT[$count][0]\n";
					#print "Percent $percent\n";
					print FILE "$CONTEXT[$count][1]\t"; # Hit
					print FILE "$CONTEXT[$count][2]\t"; #Start
					print FILE "$CONTEXT[$count][3]\t"; #stop
					print FILE "$color\t"; #color
					print FILE "$refORGANISMS->{$orgs}\t"; #org name
					print FILE "$CONTEXT[$count][4]\t"; #Funcion
					print FILE "$CONTEXT[$count][0]\t"; #gen id
					print FILE "$percent\n"; #PErcent of identity
					print FILE2 ">$hit\n$amin\n";
					}
				else{
			#		if($verbose){	print "Different contigs $contig != $contig0!!\n";}
					}
				}
			else {
			#	if ($verbose){print "Hit #$hit# is empty!!\n";}
			      }
			$count++;
			}
		}
close FILE;
close FILE2;
}
#__________________________________________________________________________________________________________________________
sub getInfo{		## Read the txt
	my $peg=shift;
	my $orgs=shift;
	my $Grep=`grep 'peg.$peg\t' GENOMES/$orgs.txt`;
	
	#print "Org $orgs\nGrep $Grep\n";

	my @sp=split(/\t|\n/,$Grep);
	my $contig=$sp[0];	
	my $hit=$sp[1];
	if ($hit=~/gb/){$hit=~s/gi\|\d*\|gb\|\w*.\w*\|//;}
	my $start=$sp[4];
	my $stop=$sp[5];
	my $dir=$sp[6];
	my $func=$sp[7];
	my $amin=$sp[12];

	#print "Enter to continue on getInfo\n";
	#my $pause=<STDIN>;
	#print "\norg $orgs! peg ¡$peg! hit $hit start $start stop $stop dir $dir func $func\n\n";	
	#print "Grep $Grep\n\n";
	return ($hit,$start,$stop,$dir,$func,$contig,$amin);
}

## Hash of arrays {Hit}->[GenClose:start,stop,direction,function]
## Second Color Search a context, Repeat the script for each sequence in the cluster
sub getSeq{
	my $peg=shift;
	my $orgs=shift;
	my $Grep=`grep 'peg.$peg\t' GENOMES/$orgs.txt`;
	my @sp=split("\t",$Grep);	
	my $hit=$sp[1];
	my $seq=$sp[12];
#	print "hit $hit start $start stop $stop dir $dir func $func\n\n";	
	return ($hit,$seq);
}
## Hash of arrays {Hit}->[GenClose:start,stop,direction,function]
#____________________________________________________________________________________

sub getGenesContigReference{
         my $pegRef=shift;
         my $org=shift;
         my $clusterSize=shift;
         my $Grep=`grep 'peg.$pegRef\t' GENOMES/$org.txt`;
         my @sp=split("\t",$Grep);
         my $contigRef = $sp[0];
         my $peg;
         my %seqSameContig; 
     
#	if ($verbose){print "pegRef $pegRef\norg#$org#\nclusterSize $clusterSize\nGrep $Grep\nContigref $contigRef\nPeg $peg\n";}
        (($pegRef - $ClusterSize) >= 0) ? ($peg=$pegRef-$clusterSize):($peg=0);
	
         while($peg<=$pegRef+$clusterSize){
                 #$peg++;
                 $Grep=`grep 'peg.$peg\t' GENOMES/$org.txt`;
                 @sp=split("\t",$Grep);
                 my $contig= $sp[0];
		#print "contig: $contig \n";
                 if($contig and $contigRef eq $contig){
                         #print "$sp[1] \n";
                         $seqSameContig{$sp[1]}=$sp[12];
			# print "$seqSameContig{$sp[1]} \n";
                 }
                 $peg++;
         }
         #print "$sp[12] \n";
         #for my $seq (keys %seqSameContig){
         #       print "$seq  $seqSameContig{$seq}\n";
         #}
         return %seqSameContig;
 }


#_____________________________________________________________________________________
sub header{
	my @LISTA=@_;
	open(OUT, ">Concatenados.fna") or die "Couldn't open Concatenados.fna";

	foreach $num (@LISTA){
		#print "num $num\n";
	  	open(EACH, "$num.fna") or die "Could not open file $num.fna $!";
  		while(my $line=<EACH>){
		   	chomp($line);
    			if($line =~ />/){
			      print OUT "$line|$num\n";	
		    		}
    			else{
      				print OUT "$line\n";
    				} 
    			}#end while EACH
  		close EACH;
		#print "File $num done\n";

		}#end 

	close OUT
	}

#_____________________________________________________________________________________
sub makeDB{
	my $query_name=shift;
	my $DB=shift;              
	my $type=shift;
	my @LISTA=@_;
#	my $genome;
   
        open(OUT, ">$query_name/TempConcatenados.faa") or die "Couldn't create $query_name/TempConcatenados.faa\n $!";
           #     open(ALL, "lista.$num") or die "Couldn't open lista.$num \n $!";

        foreach my $genome (@LISTA){
               if($verbose){print "I will open  #GENOMES/$genome\.faa#\n";}
                #<STDIN>;
               open(EACH, "GENOMES/$genome.faa") or die "Couldn't open GENOMES/$genome\.faa $!";;
               while(my $line=<EACH>){
                         chomp($line);
                         if($line =~ />/){
                                 print OUT "$line|$genome\n";
                                                #<STDIN>;  
                                }
                          else{
                                  print OUT "$line\n";
                                }     
                       }#end while EACH
                                close EACH;
                }#end while ALL
             #   close ALL;
                close OUT;

	if ($type eq 'nuc'){
		`makeblastdb -in TempConcatenados.fna -dbtype nucl -out $DB.db`;
			print "nucleotide db was created \n";

		}
	elsif($type eq 'prots'){
                `makeblastdb -in $query_name/TempConcatenados.faa -dbtype prot -out $DB.db`;
                print "Protein db was created \n";
	}
}
#___________________________________________________________________________
sub MakeBlast{
	my $query_original=shift;
	my $MakeDB=shift;
	my $type=shift;
	my $query_name=shift;
	my $evalueL=shift;
	my $DBname=shift;
	my $bitscore=shift;
	my $num=shift;
	my $genome_dir=shift;
	my $rast_ids=shift;
	my @LISTA=@_;
	my $listfile='lista.'.$num;
#       if ($verbose){print "DB $DBname\nMakeDB $MakeDB\ntyp $type\queries $query_name\nevalueL $evalueL\nbitscore $bitscore\nnum $num\ngenome dir $genome_dir\nrast ids $rast_ids\nLISta @LISTA\n";}
	open FILE, ">$query_original/$listfile" or die "Could not open file $query_original/$listfile" ;
        
        if ($MakeDB==1){foreach my $num (@LISTA){print FILE "$num\n";}}
        else{for (my $i=1;$i<=$num;$i++){	print FILE "$i\n";}		}
	
	close FILE;

	if ($MakeDB==1){
	## Make Database from concatenados.faa (PRODUCE CONCATENADOS.faa)
		if ($type eq 'nuc'){
			print"$type type\n";
			print"Doing blast nucleotide database\n";
			header(@LISTA);
			makeDB($query_name,$DBname,$type,@LISTA);
			blastnSeq($evalueL,$query_name);	
			}
	
		elsif($type eq 'prots'){
			print"$type type\n";
			print "Aminoacid data will be analised\n";
			`header.pl $genome_dir $rast_ids $query_name`;


			print "Making blast db\n";
			makeDB($query_name,$DBname,$type,@LISTA);

			blastpSeq($query_original,$evalueL,$query_name,$DBname,$bitscore);	


			}
		else {
			print"$type is not an accepted database type\n";
			}

		}
	else{ ##Si no existe BAse de datos Concatenados.faa poner un warning
		if ($type eq 'nuc'){
			blastnSeq($evalueL,$query_name);	
				
			}

		elsif($type eq 'prots'){
			blastpSeq($query_original,$evalueL,$query_name,$DBname,$bitscore);	
			}
		else {
			print"$type is not an accepted database type\n";
			}	
		}
	}
#_________________________________________________________________________________________
##Subs___________________________________________________________________________________
sub blastnSeq{
	my $e=shift;
	my $queries=shift;
	if (-e 	"$queries.parser"){unlink ("$queries.parser");}	if (-e 	"$queries.BLAST"){unlink ("$queries.BLAST");}
	`blastn -db $DB.db -query $queries -outfmt 6 -evalue $e -num_threads 4 -out $queries.BLAST`;
	`blastn -db $DB.db -query $queries -evalue $e -num_threads 4 -out $queries.parser` ;
	open (PARSER,"$queries.parser") or die "Could not open $queries.parser $!";
	my %SEQ;
	my $name;
	foreach my $line (<PARSER>){
		chomp $line;
		$line=~s/\r//;
		if ($line=~m/>/){
			$name=$line;
			$SEQ{$name}="";
			#print "LINE $name\n";
			}
		if ($line=~/Sbjct/){
			#print "BEFORE $line\n";
			$line=~s/[^ACGT]//g;

			#print "AFTER $line\n";
			$SEQ{$name}.=$line;
			
			}
		}
	close PARSER;
	unlink ("$queries.parser");

	open (PARSER,">$queries.parser") or die "Could not open $queries.parser $!";

	foreach my $KEY (keys %SEQ){
		print PARSER "$KEY\n$SEQ{$KEY}\n";
		}
	close PARSER;
	#if (-e BLAST ){system (rm -r BLAST);}
	#system(mkdir BLAST);
	#print "blast has run\n";
	#print "\nList $list#\n";
	#print "Orthology list search starts \n";
	}
#_____________________________________________________________________________________
sub blastpSeq{
	my $query_original=shift;
	my $e=shift;
	my $query_name=shift;
	my $DBname=shift;
	my $bitscore=shift;

#	if ($verbose) {print"Now we will start the blast  with evalue $e name $name database $DBname and bitscore $bitscore\n";}
	if (-e 	"$query_original/$query_name.parser"){unlink ("$query_original/$query_name.parser");}	if (-e 	"$query_original/$query_name.BLAST"){unlink ("$query_original/$query_name.BLAST");}
	`blastp -db $DBname.db -query $query_original/$query_name.query -outfmt 6 -evalue $e -num_threads 12 -out $query_original/$query_name.BLAST.pre`;
	open (PREBLAST,"$query_original/$query_name.BLAST.pre") or die "Could not open $query_original/$query_name.BLAST.pre $!";
	open (BLAST,">$query_original/$query_name.BLAST") or die "Could not open $query_original/$query_name.BLAST $!";
#	open (PARSER,">$query_original/$query_name.PARSER") or die "Could not open $query_original/$query_name.BLAST $!";  #Salva el fasta
        
	my @HITS;
	
	foreach my $line (<PREBLAST>){
                chomp $line;
			#print "$line\n";
		my @columns=split("\t",$line);
		my $score=$columns[11];
			
		if ($score>=$bitscore){
			#print "$columns[1],: Score $score\n";
                        print BLAST "$line\n";
			push(@HITS,$columns[1]);
                        }
		}

	foreach my $hit(@HITS){
	#print "This is a hit ¡$hit!\n";
	}

	`blastp -db $DBname.db -query $query_original/$query_name.query -evalue $e -num_threads 4 -out $query_original/$query_name.parser.pre` ;
	open (PREPARSER,"$query_original/$query_name.parser.pre") or die "Could not open $query_original/$query_name.parser.pre $!";
	open (PARSER,">$query_original/$query_name.parser") or die "Could not open $query_original/$query_name.parser $!";
	my %SEQ;
	my $key;
	foreach my $line (<PREPARSER>){
		chomp $line;
		$line=~s/\r//;
		if ($line=~m/>/){
			$key=$line;
			$key=~s/>\s*//;
			#print "parser line: $key \n";
			if ($key~~@HITS){
				$SEQ{$key}="";
				}
			}
		if ($line=~/Sbjct/){
			#print "BEFORE $line\n";
			$line=~s/[0-9]*//g;
			$line=~s/\s//g;
			$line=~s/-//g;
			$line=~s/Sbjct//;
			#print "AFTER $line\n";
			if (-exists $SEQ{$key}){
				#print "AFTER $line\n";
				$SEQ{$key}.=$line;
				}
			}
		}
	foreach my $hit (keys %SEQ){
		print PARSER ">$hit\n$SEQ{$hit}\n";
		#print ">$hit\n$SEQ{$hit}\n";
			}
	close PARSER;
	close PREPARSER;
	close PREBLAST;
	close BLAST;
#	`rm *.pre`;
	if ($verbose){
		print "verbose $verbose\n";
		print "BLAST and PARSER files were created for $name.query\n";
		}
	}
#____________________________________________________________
#_____________________________________________________________________________________
sub BestHits{ ##For a given query
	my $query_original=shift; ## Original query name for folder
	my $name=shift; ## blast query variabl
	my $refHits=shift;
	my $refAllHits=shift;
#/	open FILETEST, ">>aver" or die "Couldn run test";

	open FILE,  "$query_original/$name.BLAST" or die "I can not open the input FILE $query_original/$name.BLAST\n";
#	print "initialize Hash BestHits\n";
	$refHits->{$name}=();
	$refAllHits->{$name}=();

	while (my $line=<FILE>){
		chomp $line;
	#	print "Blast line: $line\n";
		my @sp=split("\t",$line);
		my @sp1=split('\|',$sp[1]);
		my @sp2=split('\.',$sp1[1]);
		my $peg=$sp2[3]; my $org=$sp1[2];my $percent=$sp[2];
#		print("Peg $peg\tOrg $org\t Percent $percent\n");

		if (!exists $refHits->{$name}{$org}){
			$refHits->{$name}{$org}=[0]; # setting $refHits->{$name}{$org}[0]=0;
			$refAllHits->{$name}{$org}=[]; # setting $refHits->{$name}{$org}[0]=0;
#			print "Hit found for organism $org\n";
			}

		if($refHits->{$name}{$org}[0]<$percent){
#			print "Second Hit found for organism $org\n";
			$refHits->{$name}{$org}=[$percent,$peg];
			####### GRAN DUDA POR PARSEAR  aaaah ya 
			}

		push(@{$refAllHits->{$name}{$org}},"$peg\_$percent");
#		print FILETEST "$name-> $org-> $peg\_$percent\n ";
#		print("Peg $refHits->{$name}{$org}[1]\tOrg $org\tPercent $refHits->{$name}{$org}[0] \n\n");

		}
	close FILE;
#	close FILETEST;
}
#________________________________________________________________________________________________


## READ QUERY
sub ReadFile{
my $queries=shift;
	open (FILE,"$queries") or die "I can not open the input FILE #$queries# $!\n";


	my %query;
	my $key="";
	while (my $line=<FILE>){
		chomp $line;
		$line=~s/\r//;
		if($line=~m/>/){
			$key=">".$queries;
			$key=~s/.query//;
			my @sp=split(" ",$line);			
			$sp[0]=~s/\>//;
			$key.="_".$sp[0];
			$query{$key}="";		
			}
		else{
			$query{$key}.=$line;		
			}
		}

	if($verbose){
		print "I will use as query\n";
		for my $keys (keys %query){
			print("$keys\n$query{$keys}\n");
			}
		}
	return %query;
}

#________________________________________________________________________________
sub BlastColor{
	my $query_name=shift;
	my $peg=shift;
	my $special_org=shift;
	my $cluster_radio=shift;
	my $num=shift;
	my $eClust=shift;
	my $DBname=shift;
	my $genome_dir=shift;
	my $rast_ids=shift;
	my $refCLUSTER=shift;
	my @LISTA=@_;

	my %CLUSTERcolor;
	my $count=2;
	my %clusterGenes = getGenesContigReference($PEG,$special_org,$cluster_radio);

	my $totalGenes = keys %clusterGenes;
	my $genesUser = 1+$ClusterSize*2;
	#print "total: $totalGenes users: $genesUser \n";
	#<STDIN>;
	if($totalGenes <  $genesUser){
		print "$totalGenes gen were found surrounding query, cluster radio can not exceed this radio. \n ";
	}

        for my $seq (keys %clusterGenes){
                my $hit = $seq;
                my $sequence = $clusterGenes{$seq};
                $hit=~m{\.peg\.(\d+)};  
                my $i = $1;             
                #print(">$hit\n$sequence");

                ## print filesnamed Cluster_peg.query with sequence of the neighbour
                if($sequence ne ""){
                        open(QUERY,">$query_name/Cluster$i.query") or die"Could not open cluster file Cluster$i.query $! \n ";
                        print QUERY ">$hit\n$sequence";         
                        #print ">$hit\n$sequence";
                        close QUERY;
                        }
		## Do blast for each one
                my $nameClust="Cluster$i";
                MakeBlast($query_name,0,$type,$nameClust,$eClust,$DBname,0,$num,$genome_dir,$rast_ids,@LISTA);
		                ## Save BEst Hits in a hash
                my %HitsClust; my %AllHitsClust; BestHits($query_name,$nameClust,\%HitsClust,\%AllHitsClust);

                ## %CLUSTER{$peg}={peg1_org1,peg2_org2,...}
                $refCLUSTER->{$i}=[];
                my $color=$count;

                #print "## Hits for $i on the cluster of $special_org\n";
                for my $HIT(keys %AllHitsClust){
                        for my $orgs (sort keys %{$AllHitsClust{$HIT}}){
                                my @pegsClust=@{$AllHitsClust{$HIT}{$orgs}};
                                #my $peg=$AllHitsClust{$HIT}{$orgs}[1];
                                foreach my $peg_percent (@pegsClust){
                                        my @sp=split("_",$peg_percent);
                                        my $peg=$sp[0]; my $percent=$sp[1];
                                        if(!exists $CLUSTERcolor{$peg}){
                                                $CLUSTERcolor{$peg}=[];
                                                }
                                        #print "org $orgs PEg:$peg\n";
                                        my $save=$peg."_".$orgs;
                                        push(@{$refCLUSTER->{$i}},$save);
                                        #push(@{$refCLUSTER->{$i}},$save);
                                        if (!exists $CLUSTERcolor{$peg}[$orgs]){
                                                $CLUSTERcolor{$peg}[$orgs]=[];
                                                }
                                        push(@{$CLUSTERcolor{$peg}[$orgs]},"$color\_$percent");
                                        #print "$color $percent -> ClusterColor Â¡@{$CLUSTERcolor{$peg}[$orgs]}!\n";
                                        #print("count #$count# color #$color#, peg #$peg#, orgs #$orgs# yo #$CLUSTERcolor{$peg}[$orgs]#\n");
                                        }
                                }
                        }
                $count++;      

	}
	
	return %CLUSTERcolor;
}
#__________________________________________________________________________________________________
sub setColor{
	my $peg=shift;
	my $orgs=shift;

	my $colorF=0;
	my $percentF=0;
	
	#print "Peg $peg, Org $orgs \n ";
	if (exists $CLUSTERcolor{$peg}[$orgs]){ ## Cualquier peg en cualquier organismo
		if ($verbose) {print "Array @{$CLUSTERcolor{$peg}[$orgs]}\n";}
		foreach my $color_percent (@{$CLUSTERcolor{$peg}[$orgs]}){ ## Puede parecerse a distintos miembros del cluster indicados por los colores, el numero de color es el numero de gen en el cluster
			my @sp=split("_",$color_percent); ## viene acompaÃ±ado de su porcentaje
			my $colorInHash=$sp[0]; 
			my $percentInHash=$sp[1];
			#print "$color_percent Color en hash $colorInHash PErcent in Hash $percentInHash\n";
			if($percentInHash>$percentF and $colorInHash ne ""){ #Escogemos el de mejor porcentaje
				#print "$percentInHash > $percentF\n then";
				$colorF=$colorInHash; ##Selects the Hit y dejamos ese color
				$percentF=$percentInHash;
				#print "color = $colorInHash:$colorF\n ";
				}

			}
		}
	if($verbose){	print "Color $colorF Percent $percentF\n\n";}
	return $colorF,$percentF;
	}
#_______________________________________________________________________________________
sub printVariables{
	if ($verbose ){
		if($MakeDB){ print "MakeDB $MakeDB\n";}
		print"type $type\n";
		print "Queries $queries\n";
		print "Special Organism $special_org\n";
		print "e_value $e_value\n";
		print "bitscore $bitscore\n";
		print "cluster radio $cluster_radio\n";
		print "list $list\n";
		print "number $num\n";
		print "name folder $name\n";
		print "dir $dir\n";
		print " verbose  $verbose\n";
		}
	}
