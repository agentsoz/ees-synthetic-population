
SHP="SCS-Addresses-Subset"

unzip $SHP.zip
INPUT=$SHP'/'*.shp
echo write each feature to text file
ogrinfo -al $INPUT > shp_file.txt
echo get coordinate for each instance
sed -n 's/POINT[[:space:]](*//p' shp_file.txt | gdaltransform -s_srs EPSG:4326 -t_srs EPSG:32754 -output_xy > test.txt
echo remove non relevant entries
sed -i '' '/-/d' test.txt
echo add header
sed -i '' '1i\
xcoord ycoord\
' test.txt
echo add commas, convert to csv
sed -i '' 's/ /,/g' test.txt
mv test.txt test.csv
echo convert orig. shp to csv
ogr2ogr -f "CSV" test1.csv $INPUT
echo Append count column
awk -F "\"*,\"*" '{print $0fs",1"}' test1.csv>test2.csv
sed -i '' 's/Type,1/Type,Count/g' test2.csv
echo merge two csvs
paste -d, test2.csv test.csv > Locations.csv
echo remove junk
rm shp_file.txt
rm test*
rm -r $SHP/
echo Fix dodgy "Type" entries
# #set all residentials to 0
# sed -i '' 's/House,Residential,1/House,Residential,0/g' Locations.csv
# #Select relevant locales
# awk  'BEGIN {OFS=FS=","} {if ($12=="ANGLESEA"&&$17=="Residential") $18=1;print}' Locations.csv> test3.csv
# awk 'BEGIN {OFS=FS=","} {if ($12=="AIREYS INLET"&&$17=="Residential") $18=1;print}' test3.csv > test4.csv
# awk 'BEGIN {OFS=FS=","} {if ($12=="FAIRHAVEN"&&$17=="Residential") $18=1;print}' test4.csv> test3.csv
# awk 'BEGIN {OFS=FS=","} {if ($12=="JAN JUC"&&$17=="Residential") $18=1;print}' test3.csv> test4.csv
# awk 'BEGIN {OFS=FS=","} {if ($12=="TORQUAY"&&$17=="Residential") $18=1;print}' test4.csv> test3.csv
# awk 'BEGIN {OFS=FS=","} {if ($12=="LORNE"&&$17=="Residential") $18=1;print}' test3.csv> Locations.csv
# awk 'BEGIN {OFS=FS=","} {if ($12=="BELLS BEACH"&&$17=="Residential") $18=1;print}' test3.csv> Locations.csv
# awk 'BEGIN {OFS=FS=","} {if ($12=="BELLBRAE"&&$17=="Residential") $18=1;print}' test3.csv> Locations.csv
# awk 'BEGIN {OFS=FS=","} {if ($12=="BREAMLEA"&&$17=="Residential") $18=1;print}' test3.csv> Locations.csv
# awk 'BEGIN {OFS=FS=","} {if ($12=="BREAMLEA"&&$17=="Residential") $18=1;print}' test3.csv> Locations.csv
# awk 'BEGIN {OFS=FS=","} {if ($12=="BELMONT"&&$17=="Residential") $18=0;print}' test3.csv> Locations.csv
# awk 'BEGIN {OFS=FS=","} {if ($12=="CERES"&&$17=="Residential") $18=0;print}' test3.csv> Locations.csv
sed -i '' 's/House,,1/House,Residential,0/g' Locations.csv
sed -i '' 's/Business district/Business District/g' Locations.csv
sed -i '' 's/Caravan Park,1/Caravan Park,1000/g' Locations.csv
sed -i '' 's/Hotel,1/Hotel,1000/g' Locations.csv
echo Add "Out of Region" locations
echo '"999997","0","0","0",,,,,,,,APOLLO BAY,,,,,Out of Region,1500,726428.3187297015,5706161.232068798' >> Locations.csv
echo '"999998","0","0","0",,,,,,,,COLAC,,,,,Out of Region,1500,725868.5478,5753291.5198' >> Locations.csv
echo '"999999","0","0","0",,,,,,,,MELBOURNE,,,,,Out of Region,12000,841924.6,5808324.9' >> Locations.csv
echo '"999986","0","0","0",,,,,,,,MOOLAP,,,,,Hotel,1000,799974.9,5769633.2' >> Locations.csv
echo '"999987","0","0","0",,,,,,,,NEWTOWN (GEELONG),,,,,Hotel,2000,792546.4,5771781.5' >> Locations.csv
echo '"999988","0","0","0",,,,,,,,GROVEDALE,,,,,Hotel,1000,792688.5,5766864.8' >> Locations.csv
echo '"999989","0","0","0",,,,,,,,TORQUAY,,,,,Hotel,1000,791461.3,5753462.4' >> Locations.csv
echo '"999990","0","0","0",,,,,,,,JAN JUC,,,,,Hotel,500,788520.0,5750951.7' >> Locations.csv
echo '"999991","0","0","0",,,,,,,,ANGLESEA,,,,,Hotel,1000,777687.6,5743422.0' >> Locations.csv
echo '"999992","0","0","0",,,,,,,,AIREYS INLET,,,,,Hotel,500,771390.61,5738850.69' >> Locations.csv
echo '"999993","0","0","0",,,,,,,,MOGGS CREEK,,,,,Hotel,500,767176.7,5737906.4' >> Locations.csv
echo '"999994","0","0","0",,,,,,,,BIG HILL (LORNE),,,,,Hotel,1000,762412.2,5734721.3' >> Locations.csv
echo '"999995","0","0","0",,,,,,,,LORNE,,,,,Hotel,1000,759297.17,5730154.62' >> Locations.csv
echo '"999996","0","0","0",,,,,,,,CONNEWARRE,,,,,Hotel,1000,800738.6,5758537.0' >> Locations.csv
echo '"999981","0","0","0",,,,,,,,LORNE,,,,,Festival,20000,751798.35,5732724.89' >> Locations.csv
