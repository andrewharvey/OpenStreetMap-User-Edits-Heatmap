#!/usr/bin/perl -w

# Info: 
# Author: Andrew Harvey (http://andrewharvey4.wordpress.com/)
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

#pass in a list of changeset ids. eg.
#5302850
#5302790
#5302723
#5301534

#it will then download them all (if file doesn't already exsist).

use strict;

while (my $line = <STDIN>) {
    chomp $line;
    print "Getting 2 files for id $line...\n";
    `wget -nc -O "xmls/$line.xml" "http://www.openstreetmap.org/api/0.6/changeset/$line"`;
    `wget -nc -O "xmls/$line-data.xml" "http://www.openstreetmap.org/api/0.6/changeset/$line/download"`;
}
