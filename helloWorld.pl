use strict;
use warnings;

print "HelloWorld\n";
# Try readFile

print "Now I will read a file\n";
open (FILE, "1308.query") or die "Couldn't open query tfile $!";
my $firstline = <FILE>;
print "First line $firstline has been readed correctly\n";
print "13File has been readed correctly\n";

#`cat GENOMES/*.faa> Concatenados.faa`;
#`makeblastdb -in Concatenados.faa -dbtype prot -out ProtDatabase.db`;
#print "La base recibio formato\n\n";
#`blastp -db Concatenados.db -query 1308.query -outfmt 6 -evalue .001`;

#`Gblocks `;
close FILE;

exit;
# Try blast
# Try muscle
# Try Gblocks
# Try quicktree
#Try newickTools
#Write great on a file
# Say Great

