#!/bin/bash
 lynx -nonumbers -dump http://archive.ics.uci.edu/ml/datasets.html | grep 'datasets/'| sort | uniq > linksfile

read name
link=$(grep -im1 $name linksfile)
echo link is $link
echo link end
#echo $link

lynx -nonumbers -dump $link > abb.html
grep 'https' abb.html | rev | cut -d "'" -f 2 | rev > newlinks
 #cat newlinks
(grep -i "/$" newlinks)>dataset

lynx -nonumbers -dump `cat dataset` > abc
grep 'https' abc | rev | cut -d "'" -f 2 | rev > acc
b=$(grep -i ".data$" acc)
disc=$(grep -i ".names" acc)






#str2=`cut -d '/' -f 6 dataset`

#a=`cat dataset`
#c=".data"
#b=$a$str2$c
#echo "b is  ......... $b"



#disc=$(grep -i ".names" newlinks )
echo $disc
lynx -nonumbers -dump $disc | tee description
lynx -nonumbers -dump $b | tee Odataset.csv
