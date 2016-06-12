#!/usr/bin/perl -I/usr/local/lib/perl5/site_perl/5.20.3

use SVG;
use strict;
use warnings;
use Getopt::Long;
use Cwd;
####################################################################
# Need to improve: Resize window for more gene
## Check genes are on the same contig
## This script only intetransoform color code given on readText on colored arrows
#
####################################################################3
############### set canvas 
#my @CLUSTERS=qx/ls *.input/; 	## Read all input Uncomment to read all
##############
#print "ARG 1 $ARGV[1]\n";
my $rescale=$ARGV[0]; 		## Arrow horizontal size, greater values of this parameter would allow to observe more genes
my @CLUSTERS=split(',',$ARGV[1]); 	## Read all input Uncomment to read all
my $nClust=scalar @CLUSTERS; 	#number of cluster (until now one per organism)
				#3 Used to draw lines
my $w=800;  			## Size of the window
my $t=10; 			##Traslation factor horizontal
#if(!$ARGV[1]){$t=20;} 		##If there is not tree, there is not translation
my $tv=0; 			##Translation factor Vertical
my $s=16.3; 			#Vertical Separation factor
my $h=100*($nClust); 		# 100 of heigth for draw each organisms
my $text=1; 			##Yes NO organism name
my $grueso=16.0;		## Grosor de las flechas
my %ColorNames=Fill_Colors();
my $cutleft=0;				
my $verbose;
#################################################################################
#################################################################################

    # create an SVG object with a size of 40x40 pixels
my $svg = SVG->new(  	
			width  => 1000,
			height => $h,
			onload=>'Init(evt)',
			onmousemove=>' GetTrueCoords(evt); 
			ShowTooltip(evt, true)',
   			onmouseout=>'ShowTooltip(evt, false)'
			);
my $tag = $svg->script(-type=>"text/ecmascript");


#########################################################
######## Main 

Draw(\@CLUSTERS,$s,$t,$tv,$w,$cutleft,$grueso,\%ColorNames, $rescale); 
	#Draw(\@CLUSTERS,$s,$t,$tv,$w,$cutleft,$grueso,\%ColorNames); 
#_________________________________________________________________

#####################################################################
##Html output (Sending files to firefox
#####################################################################
open (OUT, ">Contextos.svg") or die $!;
    # now render the SVG object, implicitly use svg namespace
print OUT $svg->xmlify;
close OUT;
	#system "firefox $file.svg";
`perl -p -i -e 's/&//' Contextos.svg`;
`perl -p -i -e 'if(/\<polygon/)\{s/title=\"/\>\n\<title\>/g;if(m{\/\>\$})\{s{\" \/\>}{\<\/title\>\<\/polygon\>};\}\}else\{if((!/^\t/) and m{\/\>})\{s{\" \/>}{<\/title><\/polygon>};\}\}' Contextos.svg`;


##################################################################
###    subs ######################################################
##################################################################
sub Draw{
	my ($refCLUSTERS,$s,$t,$tv,$w,$cutleft,$grueso,$refColorNames,$rescale)=@_;
	my @YCOORD;
	my %CONTEXTS;
	%CONTEXTS=ReadContexts(@{$refCLUSTERS});
	my $size=scalar (keys %CONTEXTS);
	##In one svg object I have accumulated all clusters
	##May be for the function visualization we may use more than one
	@YCOORD=set_lines($size);
	# add lines
	for (my $i=0;$i<$size;$i++){
   		line($s,$t,$tv,$i,$w,$cutleft,\@YCOORD);    
 		}
		# add context
		drawContexts($s,$t,$tv,$grueso,\%CONTEXTS,$w,$refColorNames,$cutleft,\@YCOORD,$rescale);
		#Need to add in inputs YCOOR (its used in line sub)
	}

#_____________________________________________________________________________________________________

sub readTree{
	my $file=shift;
	my @YCOOR;
	print "########## Reading y coordinates\n";
	`perl readTree.pl $file`; 
	open YCOOR, "YCoordinates" or die "Could not open Ycoordinates";
	for my $line (<YCOOR>){
		chomp $line;
		my @sp=split(/\t/,$line);
		my $coord=$sp[0];
		my $node=$sp[1];
		#print "$coord->$node!\n";
		push(@YCOOR,$coord);
		}
	print "End coordinates##";
	return @YCOOR;
}

#________________________________________________________________________

sub arrow{
	my $s=shift;
	my $t=shift;
	my $tv=shift;
	my $grueso=shift;
	my $start=shift;
	my $end=shift;
	my $org=shift;
	my $dir=shift;
	my $color=shift;
	my $level=shift;
	my $DirCont=shift;
	my $w=shift;  
	my $e0=shift;
	my $func=shift;
	my $id_peg=shift;
	my $orgName=shift;
	my $cutleft=shift;
	my $refYCOORD=shift;
	my $refColorNames=shift;
	my $orgNum=shift;
	my $percent=shift;
	my $real_start=shift;
	my $real_end=shift;
  my $color1;
  my $color2;
  my $color3;
	my $opacity=$percent/100.0;
	($color1,$color2,$color3)=fillColor($color,$refColorNames);

	

  #start arrow end arrow organism number direction
  my ($u1,$u2,$u3,$u4,$u5,$v1,$v2,$v3,$v4,$v5);
  ##up start
  $u1=$start; $v1=$refYCOORD->[$org-1]-$grueso/2;
  ##down start
  $u2=$start; $v2=$refYCOORD->[$org-1]+$grueso/2;
  
  if ($dir eq "+"){
      ##down rigth
      $u3=$end-$s/10;  $v3=$refYCOORD->[$org-1]+$grueso/2;
      ##pick
      $u4=$end;  $v4=$refYCOORD->[$org-1];
     ##up rigth
     $u5=$end-$s/10; $v5=$refYCOORD->[$org-1]-$grueso/2;
  }  
  else{
      ##down left
      $u3=$end+$s/10; $v3=$refYCOORD->[$org-1]+$grueso/2;
      #pick
      $u4=$end;  $v4=$refYCOORD->[$org-1];
      #up rigth
      $u5=$end+$s/10; $v5= $refYCOORD->[$org-1]-$grueso/2;
  }  

##label
	
  my $desc="Identity:".$opacity." Organism:".$orgName." Coordinates:".$real_start." ".$real_end."\nDirection:".$dir." Gen Id:".$id_peg." Function ".$func;

	# Treating genes supermiposed
	if ($level==2){$v1=$v1+30; $v2+=30;$v3+=30;$v4+=30;$v5+=30;}
	if ($level==3){$v1=$v1+60; $v2+=60;$v3+=60;$v4+=60;$v5+=60;}

	## Reversing when hit is in contra sense direction
	if($DirCont==-1){$u1=-$u1+$w; $u2=-$u2+$w; $u3=-$u3+$w;$u4=-$u4+$w;$u5=-$u5+$w;} 



	my $init=0;
	if ($cutleft==1){$init=$w/2;}
	if ($u4>$init and $u1 < $w){
		if ($u1<0){$u1=$init;$u2=$u1; $u3=$u4-$s/10;$u5=$u3;}
		if ($u3>$w){$u3=$w;$u4=$u3;$u5=$u4; }
		my $path = $svg->get_path(x => [$u1+$t, $u2+$t, $u3+$t,$u4+$t,$u5+$t],   y => [$v1+$tv, $v2+$tv, $v3+$tv,$v4+$tv,$v5+$tv],  -type => 'polygon');

		# Then we use that data structure to create a polygon
		$svg->polygon(  %$path,title=>"$desc",style => {'fill'=> "rgb($color1,$color2,$color3)",'stroke' => 'black',
			'stroke-width' =>1,'stroke-opacity' =>  1,'fill-opacity'=> $opacity,},);
		}
	}

#______________________________________________________________________________________________

sub line{
	my $s=shift;
	my $t=shift;
	my $tv=shift;
	my $i=shift;
	my $w=shift;
	my $cutleft=shift;
	my $refYCOORD=shift;

	my $init=0;
	if($cutleft==1){$init=$w/2;}
	my $xv = [$init+$t, $w+$t];
	my $v1=$refYCOORD->[$i]+$tv;my $v2=$refYCOORD->[$i]+$tv;
	my $yv = [$v1,$v2];
	my $points = $svg->get_path(x=> $xv,y => $yv,-type => 'polyline',);
	$svg->polyline ( %$points,style => {'fill-opacity' => 0,'stroke-opacity' =>  .1,'stroke'=> 'rgb(250,123,23)'});
	#$svg->text( x  => $t-350, y  => $yv)->cdata("$i:+$tv: Ycoord $YCOORD[$i], v1: $v1"); 
	}
#______________________________________________________________________________________________
sub ReadContexts{  ###Here we read all the .input files
	my @CLUSTERS=@_;
	my %CONTEXTS;

	foreach my $context(@CLUSTERS){
		chomp $context;
		my $key=$context;
		$key=~s/\.input//;
		if($verbose){print "Key $key Context: $context \n";}

		open(FILE,$context) or die "Could not open file $context $!";	
		##For each genome a Hash of array HAsh keys:functions Array Contents: gene with that function
		#my $count=0;
		$CONTEXTS{$key}=[];
	
		while ( my $line = <FILE> ) {
			my @st=split("\t",$line); 
			
			my $start=$st[0]; #print "Start $start\n";
			if ($start eq ""){$start=0;}
			else {$start=int($start);}
			push (@{$CONTEXTS{$key}}, $start);
			
			my $stop=$st[1]; #print "Stop $stop\n";
			if ($stop eq ""){$stop=0;}
			else {$stop=int($stop);}
			push (@{$CONTEXTS{$key}}, $stop);

			my $dir=$st[2];	 #print "dir $dir\n";		
			push (@{$CONTEXTS{$key}}, "$dir");

			my $color=$st[3];
			push (@{$CONTEXTS{$key}}, $color);

			my $org=$st[4]; 
			push (@{$CONTEXTS{$key}}, $org);

			my $func=$st[5]; 
			push (@{$CONTEXTS{$key}}, $func);

			my $id_peg=$st[6];  #print "color $color#\n";
			push (@{$CONTEXTS{$key}}, $id_peg);

			my $percent=$st[7]; chomp $percent;
			push (@{$CONTEXTS{$key}},$percent);
			}	
		close FILE;			
		}

	return %CONTEXTS;
	}
#________________________________________________________________________________________________________________

# Draw an arrow for each gen for each cluster
sub drawContexts{
my $s=shift;
my $t=shift;
my $tv=shift;
my $grueso=shift;
my $refCONTEXTS=shift;
my $w=shift;
my $refColorNames=shift;
my $cutleft=shift;
my $refYCOORD=shift;
my $traslation=0;
my $Rescale=shift;
my $cont_number=0;

foreach my $context(@CLUSTERS){
		chomp $context;
		my $key=$context;
		$key=~s/\.input//;
		$cont_number++;
		my %ARROWS;

		#### Read the main hit ###############################################
		my $X0=$refCONTEXTS->{$key}[0];		
		my $E0=$refCONTEXTS->{$key}[1];
		my $e0=abs(int((($w/$Rescale)*($E0-$X0)+$w/2)));
		
		
		my $D0=$refCONTEXTS->{$key}[2]; #Direction fo the hit
		if($verbose){print "X0 $X0 D0 $D0\n";} ##Acomodar el hit deseado al principio en input file
		my $DirCont;
		if ($D0 eq '+'){ $DirCont=1;}else{$DirCont=-1;} 
		
		####### Get the orgnism NAme	
		my $orgName=$refCONTEXTS->{$key}[4]; 
	if($verbose){	print "####################\n$orgName\n###########################\n";}
		if ($text!=0){	
		##	side	$svg->text( x  => 10+$t+$w, y  => $refYCOORD->[$cont_number-1]+$tv)->cdata("$orgName ;"); }
			my @sp=split(/\./,$refCONTEXTS->{$key}[6]);
			my $gen=$sp[-1];
			$svg->text( x  => 10+$t, y  => $refYCOORD->[$cont_number-1]+$tv-20)->cdata("Genoma $key:$orgName    Gen:$gen"); 
			} ##up right;
		####################################################################

		for (my $i=0;$i<@{$refCONTEXTS->{$key}}/8;$i++){
			my $start=$refCONTEXTS->{$key}[8*$i];
			my $stop=$refCONTEXTS->{$key}[8*$i+1];
		#	print "start $start stop $stop\n";
			#if ($start ne ""){my $s1=int((($w/$Rescale)*(int($start)-$X0)+$w/2)); }
			my $s1=int((($w/$Rescale)*(int($start)-$X0)+$w/2)); 
			#if ($stop ne ""){my $e1=int((($w/$Rescale)*(int($stop)-$X0)+$w/2));}
			my $e1=int((($w/$Rescale)*(int($stop)-$X0)+$w/2));
			my $dir=$refCONTEXTS->{$key}[8*$i+2];
			my $color=$refCONTEXTS->{$key}[8*$i+3];
			my $func=$refCONTEXTS->{$key}[8*$i+5];
			my $id_peg=$refCONTEXTS->{$key}[8*$i+6];
  			my $percent=$refCONTEXTS->{$key}[8*$i+7];

			if($verbose){print "Key Start $start->$s1, stop $stop->$e1, dir $dir, \n";}
			if($dir eq '+'){
			$ARROWS{$s1}=[$s1,$e1,$key,$dir,$color,$DirCont,$w,$e0,$func,$id_peg,$percent,$start,$stop];
					}
			else{
			$ARROWS{$e1}=[$s1,$e1,$key,$dir,$color,$DirCont,$w,$e0,$func,$id_peg,$percent,$start,$stop];
					}
		}
		### Once I have all arrows on a cluster I sorted them and I set the levels, need to change levels to real coordinates not translated ones
		my $level=1; my $count=0; my $lastStop=0;	
                for my $arrow(sort keys %ARROWS){
			my $s1=$ARROWS{$arrow}[0];
			my $e1=$ARROWS{$arrow}[1];
			my $key=$ARROWS{$arrow}[2];
			my $dir=$ARROWS{$arrow}[3];
			my $color=$ARROWS{$arrow}[4];
			my $dirCont=$ARROWS{$arrow}[5];
			my $w=$ARROWS{$arrow}[6];
			my $e0=$ARROWS{$arrow}[7];
			my $func=$ARROWS{$arrow}[8];
			my $id_peg=$ARROWS{$arrow}[9];
			my $percent=$ARROWS{$arrow}[10];
			my $start=$ARROWS{$arrow}[11];
			my $stop=$ARROWS{$arrow}[12];

		#	if ($count>=1){ ##From level 1 we can go level 2 or stay 1
		#		my $lastlevel=$level;
			
		#		if($lastlevel==2){$level=1; print "Chang from 2 to 1";}

		#		if($arrow<=$lastStop and $lastlevel==1){
		#			$level=2; print("Change form 1 to level=2\n");
		#			}
		#		elsif($arrow<=$lastStop and $lastlevel==2){
		#			$level=3; print("Change from 2 to level=3\n");
		#			}
		#		else{
		#			$level=1;
		#			}				
		#		} 	

			if ($dir eq '+'){$lastStop=$e1;}
			else{$lastStop=$s1;} $count++;
			$level=1; ##Uncomment to set everything to the same level
			arrow($s,$t,$tv,$grueso,$s1,$e1,$cont_number,$dir,$color,$level,$DirCont,$w,$e0,$func,$id_peg,$orgName,$cutleft,$refYCOORD,$refColorNames,$key,$percent,$start,$stop);
			if($verbose){print ("$s1,$e1,$key,$dir,$color,$level,$DirCont,$w,$e0,$func,$id_peg\n");		}
			}


		}
	}
#_____________________________________________________________________________________


sub Fill_Colors{
	my %ColorNames;
	my $scale = 0;
	for(my $i=1;$i<=100;$i++){
	my $color1=$scale+int(rand(255-$scale));	
	my $color2=100+int(rand(155));	
	my $color3=$scale+int(rand(255-$scale));	
	$ColorNames{$i}=$color1."_".$color2."_".$color3;
	}

	return %ColorNames;
	}


#________________________________________________________________
sub fillColor{
	my $color=shift;
	my $refColorNames=shift;
	$color=$color%100;
	my $color1; 
	my $color2;
	my $color3;
	my @sp;

  	if ($color==0){ #blanco
		$color1=255;
		$color2=255;
		$color3=255;
		}	
	else{
		@sp=split("_",$refColorNames->{$color});
		$color1=$sp[0];
		$color2=$sp[1];
		$color3=$sp[2];
		#$color1=($color*67)%250;
		#$color2=($color*(30))%250;
		#$color3=($color*(70))%250;
	
	}
  	if ($color==1){ #rojo
		$color1=254;
		$color2=30;
		$color3=30;
		}	

	return $color1,$color2,$color3;
	}



#__________________________________________________________________
sub set_lines{
	my $size=shift;
	my @YCOORD;
		for (my $i=0; $i<$size;$i++){
			$YCOORD[$i]=50+50*$i;
			}
	return @YCOORD;		
	}
#__________________________________________________________________
#or my $tag = $svg->script();
#note that type ecmascript is not Mozilla compliant
 
# populate the script tag with cdata
# be careful to manage the javascript line ends.
# Use qq{text} or q{text} as appropriate.
# make sure to use the CAPITAL CDATA to poulate the script.
$tag->CDATA(qq{
         var SVGDocument = null;
      var SVGRoot = null;
      var SVGViewBox = null;
      var svgns = 'http://www.w3.org/2000/svg';
      var xlinkns = 'http://www.w3.org/1999/xlink';
      var toolTip = null;
      var TrueCoords = null;
      var tipBox = null;
      var tipText = null;
      var tipTitle = null;
      var tipDesc = null;
      var lastElement = null;
      var titleText = '';
      var titleDesc = '';
      function Init(evt)
      {
         SVGDocument = evt.target.ownerDocument;
         SVGRoot = document.documentElement;
         TrueCoords = SVGRoot.createSVGPoint();
         toolTip = SVGDocument.getElementById('ToolTip');
         tipBox = SVGDocument.getElementById('tipbox');
         tipText = SVGDocument.getElementById('tipText');
         tipTitle = SVGDocument.getElementById('tipTitle');
         tipDesc = SVGDocument.getElementById('tipDesc');
      };
      function GetTrueCoords(evt)
      {
         // find the current zoom level and pan setting, and adjust the reported
         //    mouse position accordingly
         var newScale = SVGRoot.currentScale;
         var translation = SVGRoot.currentTranslate;
         TrueCoords.x = (evt.clientX - translation.x)/newScale;
         TrueCoords.y = (evt.clientY - translation.y)/newScale;
      };
      function ShowTooltip(evt, turnOn)
      {
         try
         {
            if (!evt || !turnOn)
            {
               toolTip.setAttributeNS(null, 'display', 'none');
            }
            else
            {
               var tipScale = 1/SVGRoot.currentScale;
               var textWidth = 0;
               var tspanWidth = 0;
               var boxHeight = 20;
               tipBox.setAttributeNS(null, 'transform', 'scale(' + tipScale + ',' + tipScale + ')' );
               tipText.setAttributeNS(null, 'transform', 'scale(' + tipScale + ',' + tipScale + ')' );
               var targetElement = evt.target;
               if ( lastElement != targetElement )
               {
                  var targetTitle = targetElement.getElementsByTagName('title').item(0);
                  if ( targetTitle )
                  {
                     titleText = targetTitle.firstChild.nodeValue;
                     tipTitle.firstChild.nodeValue = titleText;
                  }
                  var targetDesc = targetElement.getElementsByTagName('desc').item(0);
                  if ( targetDesc )
                  {
                     titleDesc = targetDesc.firstChild.nodeValue;
                     tipDesc.firstChild.nodeValue = titleDesc;
                  }
               }
               var xPos = TrueCoords.x + (10 * tipScale);
               var yPos = TrueCoords.y + (10 * tipScale);
               //return rectangle around object as SVGRect object
               var outline = tipText.getBBox();
               tipBox.setAttributeNS(null, 'width', Number(outline.width) + 10);
               tipBox.setAttributeNS(null, 'height', Number(outline.height) + 10);
               toolTip.setAttributeNS(null, 'transform', 'translate(' + xPos + ',' + yPos + ')');
               toolTip.setAttributeNS(null, 'display', 'inline');
            }
         }
         catch(er){}
       };
});
