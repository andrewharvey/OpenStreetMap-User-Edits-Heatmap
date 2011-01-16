#!/usr/bin/perl -w

# Info: Extracts coordinates of nodes from an OpenStreetMap osmChange file.
# Author: Andrew Harvey (http://andrewharvey4.wordpress.com/)
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

use strict;

use XML::XPath;
use XML::XPath::XMLParser;

if (@ARGV == 0) {
    print "Usage: $0 osmChange-file.xml [more files ...]\n";
    exit;
}

my $i = 0;
my $point_id = 0;
foreach my $file (@ARGV) {
    $i++;
    print STDERR $i." $file\n";
    
    # skip over files with no content
    if ( -z $file ) {
        next;
    }
    
    my $xp = XML::XPath->new(filename => $file);

    foreach my $type ("create", "modify") {
        foreach my $n ($xp->find("/osmChange/$type/node")->get_nodelist){
            #print "$point_id,"; #print a point id (gheat wants this)
            print $n->find('@lat')->string_value;
            print " "; # delimeter
            print $n->find('@lon')->string_value;
            print "\n";
            $point_id++;
        }
    }
}
