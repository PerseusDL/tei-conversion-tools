#!/usr/bin/perl
# Miscenalleous fixes to TEI text document which need to be moved into the XQuery code 
use strict;

my $e_input = $ARGV[0];
my $e_output = $ARGV[1];
my $e_lang = $ARGV[2];
my $norestart = $ARGV[3];

unless ($e_input && $e_output && $e_lang)
{
    die "Usage: $0 <input file> <output file> <source language>\n";
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
