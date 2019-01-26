#!/bin/bash

figlet "UNIX"
figlet "PROJECT"
### main() ###
echo "The features available :- "
echo "1- Pre-processed dataset(CSV,TXT Format)"
echo "4- Build and process dataset(CSV Format)"
echo "2- Raw image dataset"
echo "3- Evaluate your model performance"

echo ""
echo "Enter your choice:"
read ch
A=5
B=0
C=20
D=20
num=$A
CRAWLER=
OUTPUT_FLAG=-O     # For curl it changes to use '-o'
RETRY_FLAG=-t      # Default retrying flag (for wget). For curl using '--retry <num>'.
RETRY_NUM=3        # Crawler retries <num> times if here's a connection issue.
QUITE_FLAG=-q      # Turning off crawler's logging output. For curl using '-s'.
FOLLOW_REDIRECT=   # Following the redirection, in case 301 moved was returned. For curl using '-L'.
ROBOTS_CMD="-e robots=off"  # wget only, do not honor robots.txt rules.
USERAGENT_FLAG=-U  # For curl, using '-A'
USERAGENT_STRING="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.116 Safari/537.36"
RESIZE_WIDTH=$D
RESIZE_HEIGHT=$C
CRAWLER_OPT=$B
function processed(){
#(lynx -nonumbers -dump http://archive.ics.uci.edu/ml/datasets.html | grep 'datasets/'| sort | uniq )> linksfile
echo "Enter the Query:"
read name
link=$(grep -im1 $name linksfile)
#echo link is $link
#echo link end
#echo $link

(lynx -nonumbers -dump $link) > abb.html
(grep 'https' abb.html | rev | cut -d "'" -f 2 | rev) > newlinks
 #cat newlinks
(grep -i "/$" newlinks)>dataset

(lynx -nonumbers -dump `cat dataset`) > abc
(grep 'https' abc | rev | cut -d "'" -f 2 | rev) > acc
b=$(grep -i ".data$" acc)
disc=$(grep -i ".names" acc)

#str2=`cut -d '/' -f 6 dataset`

#a=`cat dataset`
#c=".data"
#b=$a$str2$c
#echo "b is  ......... $b"
echo ""
#disc=$(grep -i ".names" newlinks )
echo "ABOUT THE DATASET:"
echo ""
#echo $disc
lynx -nonumbers -dump $disc |tee description
(lynx -nonumbers -dump $b )> fin.csv
rm abc
rm acc
rm dataset
rm description
rm abb.html
rm newlinks
}

# Select crawler based on user choice
function selectCrawler() {
  which wget > /dev/null 2>&1
  if [ $CRAWLER_OPT -eq 0 ] && [ $? -eq 0  ];then
    CRAWLER=wget
    echo -e "Using wget as crawler...\n"
  else
    which curl > /dev/null 2>&1
    if [ $CRAWLER_OPT -eq 1 ] && [ $? -eq 0 ];then
      CRAWLER=curl
      OUTPUT_FLAG=-o
      RETRY_FLAG=--retry
      QUITE_FLAG=-s
      FOLLOW_REDIRECT=-L
      ROBOTS_CMD=
      USERAGENT_FLAG=-A
      echo -e "Using curl as crawler...\n"
    else
      echo -e "Neither wget nor curl was found, please check your system environment, aborting..."
      exit 1
    fi
  fi
}

# Download all images for a particular category from links stored in file.
function downloadImages() {
  from_filename=$1
  save_dir=$2
  mkdir -p $save_dir
  curr=1
  while read url
  do
    $CRAWLER $QUITE_FLAG $RETRY_FLAG $RETRY_NUM $USERAGENT_FLAG "$USERAGENT_STRING" $url $OUTPUT_FLAG $save_dir/${curr}.png && convert $save_dir/$curr.png -resize $RESIZE_WIDTH\x$RESIZE_HEIGHT! $save_dir/$curr.png &
    curr=$(($curr+1))
  done < $from_filename
}


# Parse results page, match the image urls 
function parsePage() {
  if [ -e results ];then
    rm -rf results;
  fi
  mkdir results;

  k=1
  
  while read query
  do
    echo "-> Scraping $query"
    touch results/${k}_URL-List_${query};
    for((i=1; i<=$num; i++))
    do
      (
        $CRAWLER $QUITE_FLAG $RETRY_FLAG $RETRY_NUM $ROBOTS_CMD $FOLLOW_REDIRECT $USERAGENT_FLAG "$USERAGENT_STRING" "http://images.google.com/images?q=${query}&start=$((($i-1)*20))&sout=1" $OUTPUT_FLAG results/${k}_${query}_${i}
        # Non-greedy mode, to match only image url src part.
        cat results/${k}_${query}_${i}| egrep 'src="http.*?"' -o | awk -F'"' '{print $2}' >> results/${k}_URL-List_${query}
      ) &
    done

    
    # Waiting for background jobs to finish before removing temporary files and downloading images
    wait
    (
      rm -rf results/${k}_${query}*
      downloadImages results/${k}_URL-List_${query} results/$query
    ) &

    k=$(($k+1));
  done < query_list.txt

}
if [ $ch -eq 1 ];then
	processed
elif [ $ch -eq 2 ] || [ $ch -eq 4 ];then
	echo "Enter the Queries:"
	cat > query_list.txt
	echo "Now Enter the following information:"
	echo '<number_of_images_per_category> <0 to use wget, 1 to use curl> <width> <heigth>'
	read A
	read B
	read C
	read D
	num=$A
	CRAWLER=
	OUTPUT_FLAG=-O     # For curl it changes to use '-o'
	RETRY_FLAG=-t      # Default retrying flag (for wget). For curl using '--retry <num>'.
	RETRY_NUM=3        # Crawler retries <num> times if here's a connection issue.
	QUITE_FLAG=-q      # Turning off crawler's logging output. For curl using '-s'.
	FOLLOW_REDIRECT=   # Following the redirection, in case 301 moved was returned. For curl using '-L'.
	ROBOTS_CMD="-e robots=off"  # wget only, do not honor robots.txt rules.
	USERAGENT_FLAG=-U  # For curl, using '-A'
	USERAGENT_STRING="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.116 Safari/537.36"
	RESIZE_WIDTH=$D
	RESIZE_HEIGHT=$C
	CRAWLER_OPT=$B
	selectCrawler
	parsePage
	wait
	if [ $ch -eq 4 ];then
    #cd results
		(echo "$C $D" )| python3 process.py 
		echo "Processed"
	fi
elif [ $ch -eq 3 ];then
	echo "Name your model as model.py and save it in the current directory"
	echo "DataSet is fin.csv"
  echo "Press 1 when ready:"
  read w
  echo "Please wait.Evaluating your model..."
	python3 model.py
fi

