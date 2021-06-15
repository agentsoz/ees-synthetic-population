#!/usr/bin/env bash

dir=$(dirname "$0")
shp=$dir/SCS-Locations-2021.shp
outcsv=$dir/SCS-Locations-2021.csv
echo "Extracting attributes table from $shp to $outcsv"
ogr2ogr -f "CSV" $outcsv $shp

# adjust some values (should be adjusted in input instead)
# sed -i -e 's/,Apollo Bay Region,"1000"/,Apollo Bay Region,"10"/' $outcsv
# sed -i -e 's/,West Region,"100"/,West Region,"10"/' $outcsv
# sed -i -e 's/,North West Region,"100"/,North West Region,"10"/' $outcsv

# ogrinfo -al $shp > $shpdir/xy.ogrinfo
# awk -F"[()]" '/POINT/{print $2}' $shpdir/xy.ogrinfo | \
#   gdaltransform -s_srs EPSG:4326 -t_srs EPSG:32754 -output_xy | \
#   sed 's/ /,/g' | \
#   awk 'BEGIN{print "xcoord,ycoord"}1'q \
#   > $shpdir/xy.points
