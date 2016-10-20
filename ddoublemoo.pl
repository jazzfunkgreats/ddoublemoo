#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

## 1. DETERMINE ARTIST ##

my $artist;

if (scalar(@ARGV) > 0) {
	$artist = $ARGV[0];
} else {
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
#	next unless ($_ =~ /^<a href=.*by&nbsp;D&nbsp;Double E/);
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

foreach (@lines){
	next unless ($_ =~ /pending-editorial-actions-count/); # remove all lines that aren't lyrics
	next if ($_ =~ /preload-content/); # as above
	my @tempsplit = split />/, $_; # split out lyric text only
	$tempsplit[1] =~ s/<br//;
	$tempsplit[1] =~ s/<\/a//;
	next if $_ =~ /^\[/; # reject '[hook]', '[verse]'' etc etc
	push @finallines, $tempsplit[1];
}

## 4. COWSAY MAGIC ##

my $randnum = int rand(scalar(@finallines));
system('cowsay', $finallines[$randnum]);
