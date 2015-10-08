use strict;
use warnings;
use Data::Dumper;
use utf8;
use HTML::Entities;
use XML::Twig;

binmode STDIN,  ':encoding(cp932)';
binmode STDOUT, ':encoding(cp932)';
binmode STDERR, ':encoding(cp932)';

#########################################################################
#                                                                       #
#  	TMX からプレーンテキスト抽出												#
#  																		#
#########################################################################

#Local time settings
my $times = time();
my ($sec, $min, $hour, $mday, $month, $year, $wday, $stime) = localtime($times);
$month++;
my $datetime = sprintf '%04d%02d%02d%02d%02d%02d', $year + 1900, $month, $mday, $hour, $min, $sec;

#File settings
print "Folder: ";
chomp(my $dir = <STDIN>);
chdir "$dir";

open( my $out, ">:utf8", "result_$datetime.txt" ) or die "$!:result_$datetime.txt";

my @en;
my @ja;

while (<*.tmx>){
	
	my $file = $_;
	
	my $twig = new XML::Twig( TwigRoots => {
					'//tuv[@xml:lang="en-US"]/seg' => \&output_sdlxliff_source, 
					'//tuv[@xml:lang="ja-JP"]/seg' => \&output_sdlxliff_target,
						});
						
	$twig->parsefile( $file );
	
}

#print $out $_."\n" for decode_entities(@ja);

for ( my $i=0; $i < scalar(@en); $i++ ) {
	my $en_out = $en[$i];
	my $ja_out = $ja[$i];
	print {$out} $en_out."\t".$ja_out."\n";
}

print "\n\n".'Completed!'."\n";
system ( 'pause > nul');


sub output_sdlxliff_source{
	
	my( $tree, $elem ) = @_;
	my $eng = $elem->text;
	push (@en, $eng);
	
	{
	local *STDOUT;
	local *STDERR;
  	open STDOUT, '>', undef;
  	open STDERR, '>', undef;
	$tree->flush_up_to( $elem ); #Memory clear
	}
	
}

sub output_sdlxliff_target {
	
	my( $tree, $elem ) = @_;
	my $jap = $elem->text;
	push (@ja, $jap);
	
	{
	local *STDOUT;
	local *STDERR;
  	open STDOUT, '>', undef;
  	open STDERR, '>', undef;
	$tree->flush_up_to( $elem ); #Memory clear
	}
	
}
