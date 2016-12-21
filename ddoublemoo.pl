#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

##############################################################
#	ddoublemoo.pl
#	A script to randomly generate a bar from rapgenius and
#	output it to cowsay.
#
#	Author:
#	Tom Bennett
##############################################################

## 1. DETERMINE ARTIST ##

my $artist;
my $speech = 0;
my $fire = 0;
my $cowarg = "";

if (scalar(@ARGV) >= 1) {
	foreach (@ARGV) {
		if (/^-[abdgpstwy]/) {
			$cowarg = "$_";
		} elsif (/--say/) {
			$speech = 1;
		} elsif (/--fire/){
			$fire = 1;
		} else {
			$artist = $_;			
		}
	}
	unless (defined $artist) { # if artist is not defined as an argument, default to d double =~ /\w+/
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
	next if $_ =~ /^\s*\[/; # reject '[hook]', '[verse]'' etc etc
	if ($_ =~ /^[A-Z]/) {
		$_ =~ s/<br>//; # strip html tags
		$_ =~ s/<\/a>//;
		$_ =~ s/<\/p>//;
		push @finallines, $_;
	}
	if ($_ =~ /pending-editorial-actions-count/){ # remove all lines that aren't lyrics
		next if ($_ =~ /itemprop/);
		my @tempsplit = split />/, $_; # split out lyric text only
		$tempsplit[1] =~ s/<br//;
		$tempsplit[1] =~ s/<\/a//;
		$tempsplit[1] =~ s/<\/p//;
		push @finallines, $tempsplit[1]
	}
}

if (@finallines == 0) {
	die "Unable to find lyrics! Try again...\n";
}

## 4. COWSAY MAGIC ##

my $randnum = int rand(scalar(@finallines));
my $os = OSCheck();
if ($speech == 1){
	if ($os eq 'osx'){
		system('say', $finallines[$randnum]) # if '--say' argument given, will use speech instead of cowsay
	} else {
		system('espeak', $finallines[$randnum])
	}
} elsif ($cowarg =~ /^-/){
	system('cowsay', $cowarg, $finallines[$randnum]);
} elsif ($fire == 1) {
	Fire(@finallines)	
} else {
	system('cowsay', $finallines[$randnum]);
}

sub OSCheck {
	my $os;
	if ($^O =~ 'linux'){
		$os = 'linux';
	} else {
		$os = 'osx';
	}
	return $os;
}

sub Fire {
	my @bars = @_;
	foreach (@bars) {
		system('clear');
		system('cowsay', $_);
		system('sleep 2');
	}
}
