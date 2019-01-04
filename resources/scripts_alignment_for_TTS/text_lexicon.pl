#!/usr/local/bin/perl

$txt=$ARGV[0];
$valgrind=$ARGV[1];
%lexicon={};
%phones={};

$textdata="";

open($text,"<$txt");
while($line =<$text>){
	my ($uttid,$data)=split(/"/,$line);
    $data =~ s/"(.*?)"/$1/s;
    $uttid =~ s/\(//s;
    $uttid =~ s/^\s+|\s+$//g;
    $data =~ s/[#%&\$*+()!?\.\,\']//g;
	$data =~ s/-//g;
    $data =~ s/\s+/ /g;
    @words =  split(/ /, $data);
    $textdata=$textdata."$uttid sil ";
    foreach $word(@words)
    {
    	if(length($word)>0){
	    	#print "word : $word\n";

		if( $valgrind eq 1) { system("/media/rachana/sda8/workspace-1nov18/pause_detection_toolkit/DNN_SEGMENTATION/SEGMENTATION/unified-parser/unified-parser   $word   0 0 0 0"); 
			print "in text_lexicon....\n";
			print "word : $word\n";
}
		else{  	system("/media/rachana/sda8/workspace-1nov18/pause_detection_toolkit/DNN_SEGMENTATION/SEGMENTATION/unified-parser/unified-parser   $word   0 0 0 0"); }

	    	if(open(F2, "<wordpronunciation")){
				while(<F2>) {
					chomp;
					$_ =~ s/\(set\! wordstruct \'\(//g;
					$_ =~ s/\)//g;
					$_ =~ s/[0 ]//g;
					$_ =~ s/\(//g;
					$_ =~ s/\"\"/ /g;
					$_ =~ s/\"//g;
					$comb = $_;
					$comb =~ s/ //g;
					$lexicon{$comb}=$_;
					chomp($comb);
					$textdata=$textdata."$comb ";
					#print "$_\t$comb \n";
					@monos =  split(/ /, $_);
					foreach $mono(@monos){
						$phones{$mono}=1;
						#print "$mono\n";
					}
				}
				close(F2);
			}	
		}
		
    }
    $textdata=$textdata."sil\n";
}
close($txt);
open($textdatafile,">data/train/text");
print $textdatafile $textdata;
close($textdatafile);
open($file,">data/local/dict/lexicon.txt");
print $file "$_ $lexicon{$_}\n" for (sort keys %lexicon);
close($file);
open($file,">data/local/dict/nonsilence_phones.txt");
print $file "$_\n" for (sort keys %phones);
close($file);
