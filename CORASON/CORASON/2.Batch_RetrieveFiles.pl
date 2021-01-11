###############################################################
############   Declare Functions  ############################
###############################################################
use LWP::Simple;
use globals;

sub Retrieve;
my $pass=$ARGV[1];
my $user=$ARGV[2];
my $RAST_Ids=$ARGV[0];
###############################################################
############		Main     ##############################
Retrieve($user,$pass,$RAST_Ids);

###############################################################
###############################################################

sub Retrieve{
	my $user=shift;
	my $pass=shift;
	my $file=shift;
	open FILE,  "$file" or die "I can not open the input FILE\n";
	my %orgs;
	my $count=1;
	while (my $line=<FILE>){
		chomp $line;
		print "$line\n";
		if ($line eq ""){last;}
		my @content= split(/\t/,$line);
		print "$content[0]=>$content[1]=>$content[2]\n";
		my $ID=$content[0];
		$orgs{$content[0]}=$content[1];
		`svr_retrieve_RAST_job $user $pass $ID amino_acid > GENOMES/$count.faa`;
		`svr_retrieve_RAST_job $user $pass $ID table_txt > GENOMES/$count.txt`;
		$count++;
		}
	$NUM=$count;	
	close FILE;
}

###############################################################
