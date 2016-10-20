#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

## 1. URL RIPPING ##

# my @urls = (
# 	'http://genius.com/D-double-e-street-fighter-riddim-lyrics',
# 	'http://genius.com/D-double-e-lovely-jubbly-lyrics'
# 	);

my $baseurl = 'http://genius.com/search?q=d+double+e';

my $searchhtml = qx{wget --quiet --output-document=- $baseurl};
my @search = split /\n/, $searchhtml;
my @urls;

foreach (@search){
	next unless ($_ =~ /^<a href=.*by&nbsp;D&nbsp;Double E/);
	my @urlarray = split /"/, $_;
	my $newurl = $urlarray[1];
	push @urls, $newurl;
}

## 2. LYRIC RIPPING ##

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

## 3. COWSAY MAGIC ##

my $randnum = int rand(scalar(@finallines));
system('cowsay', $finallines[$randnum]);
