#!/usr/bin/perl
# This script should only be used on texts whose citation hierarchy is defined
# in terms of divs and lines using the div and l tags.
# All it does is
# - 1. Makes sure the <text/> element has a language attribute
# - 2. Makes sure all l elements are numbered
# By default, it restarts the numbering for l elements each time a div is encountered
# If you don't want this behavior, and instead want the l numbers to be sequential regardless
# of divs (which would be the case if only the lines are part of the canonical citation scheme)
# then specify 1 as the value of the norestart argument
use strict;

my $e_input = $ARGV[0];
my $e_output = $ARGV[1];
my $e_lang = $ARGV[2];
my $norestart = $ARGV[3];

unless ($e_input && $e_output && $e_lang)
{
    die "Usage: $0 <input file> <output file> <source language> [norestart]\nE.g. $0 file.xml file_output.xml grc 1";
}
open IN, "<$e_input" or die "$!\n";
open OUT, ">$e_output" or die "$!\n";
my $l = 0;
while (<IN>)
{
    
    # make sure the <text> element has a language attribute
    if (/<text(.*?)>/)
    {
        my $atts = $1;
        unless ($atts =~ /(xml:)?lang=/)
        {
            $_ =~ s/<text(.*?)>/<text xml:lang="$e_lang" \1>/g
        } 
    }
    # make sure each <l> element has an id
    elsif (/<div/ && ! $norestart)
    {
        $l = 0;
    }
	elsif (/<l n="(\d+)"/)
	{	
		$l = $1;		
	}
	elsif (/<l>/)
	{
		++$l;
		s/<l>/<l n="$l">/;				
	}
	print OUT $_;
}
