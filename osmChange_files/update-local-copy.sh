#!/bin/sh

#download my last 100 changesets
wget -r -O last100.xml "http://api.openstreetmap.org/api/0.6/changesets?display_name=$1"

#extract the change set ids
cat last100.xml | grep -o "changeset id=\"[0-9]*\"" | sed 's/^changeset id="//' | sed 's/"$//' > csids


./getchangesets.pl < csids
