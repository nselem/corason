use strict;
## I will read trees from figtree
## and get the y names coordinates
## to align there the genomic contexts
#Asuming all names has the character "_"

my $file= $ARGV[0]; 
my @File=ReadFile($file);
my $FILE=join('',@File);
#my $FILE=~s/\n//;
my @sp=split(/text|path/,$FILE);

#print @File;
my %COORD=Coordinates(@sp);

open FILE, ">YCoordinates" or die "Could not open file coords\n";
for my $key(sort {$a<=>$b} keys %COORD){
 	print FILE "$key\t$COORD{$key}\n";
}
	close FILE;


print"$FILE\n";
sub Coordinates{
	my @sp=@_;
	my %COORD;

	my $count=0;
	for my $line (@sp){
		if ($line=~/_/){
			my @node=split(/>|</,$line);
			my @y=split(/"|\s/,$sp[$count+3]);
			
#			print "LINE $count:@node[1]!\n";
			#44.62
#			print "LINE $count+3:@y[6]!\n";
			$COORD{@y[6]}=$node[1];
			}
		$count++;
		}
	return %COORD;
}
sub ReadFile{
my $file=shift;
	open FILE,  "$file" or die "I can not open the input FILE\n";
	my @File=<FILE>;
	return @File;
	close FILE;
}

