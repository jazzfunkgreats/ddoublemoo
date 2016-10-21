#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

## 1. DETERMINE ARTIST ##

my $artist;
my $speech = 0;
my $cowarg = "";

if (scalar(@ARGV) >= 1) {
	foreach (@ARGV) {
		if (/^-[abdgpstwy]/) {
			$cowarg = "$_";
		} elsif (/--say/) {
			$speech = 1;
		} else {
			$artist = $_;			
		}
	}
	unless ($artist =~ /\w+/) { # if artist is not defined as an argument, default to d double
		$artist = 'D Double E';
	}
} else { # if there's no arguments, default to the newham general himself
	$artist = 'D Double E';
}

$artist =~ s/ /\+/g;

## 2. URL RIPPING ##

my $baseurl = "http://genius.com/search?q=$artist";

my $searchhtml = qx{wget --quiet --output-document=- $baseurl};
my @search = split /\n/, $searchhtml;
my @urls;

$artist =~ s/\+/&nbsp;/;
$artist =~ s/\+/ /g;

foreach (@search){
	next unless ($_ =~ /^<a href=.*by&nbsp;$artist/i);
	my @urlarray = split /"/, $_;
	my $newurl = $urlarray[1];
	push @urls, $newurl;
}

if (scalar(@urls) == 0) {
	die "Cannot find any artists by that name in database...\n";
}

## 3. LYRIC RIPPING ##

my $randurl = int rand(scalar(@urls));

my $html = qx{wget --quiet --output-document=- $urls[$randurl]};
my @lines = split /\n/, $html;
my @finallines;

foreach (@lines){ # first sweep for non-annotated lines
	next if ($_ =~ /preload-content/);
	next unless ($_ =~ /^[A-Z]/);
	$_ =~ s/<br>//; # strip line breaks
	$_ =~ s/<\/a>//; # strip whatever this thing is
	next if $_ =~ /^\[/; # reject '[hook]', '[verse]'' etc etc
	push @finallines, $_;
}

foreach(@lines) { # second sweep for annotated lines
	next unless ($_ =~ /pending-editorial-actions-count/); # remove all lines that aren't lyrics
	next if ($_ =~ /preload-content/);
	my @tempsplit = split />/, $_; # split out lyric text only
	$tempsplit[1] =~ s/<br//;
	$tempsplit[1] =~ s/<\/a//;
	next if $_ =~ /^\[/; 
	push @finallines, $tempsplit[1];
}

if (@finallines == 0) {
	die "Unable to find lyrics! Try again...\n";
}

## 4. COWSAY MAGIC ##

my $randnum = int rand(scalar(@finallines));
if ($speech == 1){
	system('say', $finallines[$randnum]) # if '--say' argument given, will use speech instead of cowsay
} elsif ($cowarg =~ /^-/){
	system('cowsay', $cowarg, $finallines[$randnum]);	
} else {
	system('cowsay', $finallines[$randnum]);
}