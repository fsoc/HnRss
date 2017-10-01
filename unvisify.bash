#!/bin/bash
url=$1

data=$(curl -L -s "https://unvis.it/$url")
loading=$(echo $data| grep "Loading page, please wait..."|wc -l)

if [ "$loading" -gt 0 ]
then
  sleep 5
  data=$(curl -L -s "https://unvis.it/$url")
  loading=$(echo $data| grep "Loading page, please wait..."|wc -l)
fi

# Only show content
data=$(echo $data|sed -E 's/(.*)<div class="header container">.*<\/div> (<div class="container">.*)/\2/')
echo $data
