    use strict;
    use warnings;

#$perl changeNamesWC.pl PriA RAST.ids
#perl changeNamesWC.pl PriA.Fasta.blast RAST.ids

my $file=$ARGV[0]; ##File to change
my $fileNames=$ARGV[1]; ##Information for the change
my %NAMES=read_names($fileNames);
#changenames($file);

###### OrgS Hash de arrays
sub read_names{
	my $file=shift;
	my %ORGS;
#	my $count=1;
	open (FILE,$file) or die "Could not open file";
	foreach my $line (<FILE>){
		chomp $line;
		my @sp=split("\t",$line);
		$ORGS{$sp[1]}=$sp[2];	
		print"$sp[1] $ORGS{$sp[1]}\n"	
		}
	return %ORGS;
	}
###### OrgS Hash de arrays
sub changenames{
	my $file=shift;

	open (FILE,$file) or die "Could not open file $!";
	open (SALIDA, ">$file.changed") or die "Could not open file $!";
	foreach my $line (<FILE>){
		if($line=~m/>/g){
			foreach my $id(keys %NAMES){
				chomp $line;
                                if($line=~m/$id/g){ 
 					$line=~s/$id/$NAMES{$id}/g;
 					$line=~s/>//g;
					$line=~s/fig\|/_/g;					 
					$line=">".$id."_".$line;
					$line=~s/[)(,.-]=/_/g;
					$line=~s/\)/_/g;
					$line=~s/\(/_/g;
					$line=~s/,/_/g;
					$line=~s/-/_/g;
					$line=~s/\s/_/g;	
					$line=~s/\./_/g;	
					$line=~s/__/_/g;
					print SALIDA "$line\n";
					print "$line\n";
			         	}
				}
			}	
		else{
			print SALIDA "$line";
			print "$line";
			}			
		}
	close FILE; close SALIDA;
	}

