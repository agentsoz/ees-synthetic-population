#!/usr/bin/env bash

dir=$(dirname "$0")
shp=$dir/SCS-Locations-2021.shp
outcsv=$dir/SCS-Locations-2021.csv
echo "Extracting attributes table from $shp to $outcsv"
ogr2ogr -f "CSV" $outcsv $shp
# ogrinfo -al $shp > $shpdir/xy.ogrinfo
# awk -F"[()]" '/POINT/{print $2}' $shpdir/xy.ogrinfo | \
#   gdaltransform -s_srs EPSG:4326 -t_srs EPSG:32754 -output_xy | \
#   sed 's/ /,/g' | \
#   awk 'BEGIN{print "xcoord,ycoord"}1'q \
#   > $shpdir/xy.points
