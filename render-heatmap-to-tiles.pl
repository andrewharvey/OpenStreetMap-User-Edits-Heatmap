#!/usr/bin/perl -w

# Info: 
# Author: Andrew Harvey (http://andrewharvey4.wordpress.com/)
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

use strict;

use Math::Trig;
use File::Path;

if (@ARGV < 6) {
    die "Usage: $0 points heatmap_tile_directory min_zoom max_zoom top left bottom right\n";
}

my $points = shift @ARGV;
my $tile_dir = shift @ARGV;
my $min_zoom = shift @ARGV;
my $max_zoom = shift @ARGV;
my @bbox = @ARGV;

my $min_lat = $bbox[0];
my $min_lon = $bbox[1];
my $max_lat = $bbox[2];
my $max_lon = $bbox[3];

for my $z ($min_zoom..$max_zoom) {
    my ($xmin, $ymin) = getTileNumber($min_lat, $min_lon, $z);
    my ($xmax, $ymax) = getTileNumber($max_lat, $max_lon, $z);

    print "Rendering zoom $z\n";    
    for my $y ($ymin..$ymax) {
        for my $x ($xmin..$xmax) {
            print "$x,$y ";
            my $tilebbox = join(',', Project($x,$y,$z));
            mkpath "$tile_dir/$z/$x/";
            # heatmap.py from http://www.sethoscope.net/heatmap/
            `./heatmap.py --output="$tile_dir/$z/$x/$y.png" --points="$points" --width=256 --height=256 --projection=mercator --radius=15 --decay=0.95 --extent='$tilebbox'`
        }
    }
    print "\n";
}

### Library functions
# Following code from http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#lon.2Flat_to_tile_numbers_3
# lon/lat to tile numbers
sub getTileNumber {
  my ($lat,$lon,$zoom) = @_;
  my $xtile = int( ($lon+180)/360 *2**$zoom ) ;
  my $ytile = int( (1 - log(tan(deg2rad($lat)) + sec(deg2rad($lat)))/pi)/2 *2**$zoom ) ;
  return ($xtile, $ytile);
}

# tile numbers to lon/lat
sub Project {
  my ($X,$Y, $Zoom) = @_;
  my $Unit = 1 / (2 ** $Zoom);
  my $relY1 = $Y * $Unit;
  my $relY2 = $relY1 + $Unit;
 
  # note: $LimitY = ProjectF(degrees(atan(sinh(pi)))) = log(sinh(pi)+cosh(pi)) = pi
  # note: degrees(atan(sinh(pi))) = 85.051128..
  #my $LimitY = ProjectF(85.0511);
 
  # so stay simple and more accurate
  my $LimitY = pi;
  my $RangeY = 2 * $LimitY;
  $relY1 = $LimitY - $RangeY * $relY1;
  $relY2 = $LimitY - $RangeY * $relY2;
  my $Lat1 = ProjectMercToLat($relY1);
  my $Lat2 = ProjectMercToLat($relY2);
  $Unit = 360 / (2 ** $Zoom);
  my $Long1 = -180 + $X * $Unit;
  return ($Lat2, $Long1, $Lat1, $Long1 + $Unit); # S,W,N,E
}
sub ProjectMercToLat($){
  my $MercY = shift;
  return rad2deg(atan(sinh($MercY)));
}
sub ProjectF
{
  my $Lat = shift;
  $Lat = deg2rad($Lat);
  my $Y = log(tan($Lat) + sec($Lat));
  return $Y;
}
