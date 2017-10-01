#!/bin/bash

base_url_identical () {
  url1=$(echo $1|sed -E 's/([^&]*).*/\1/')
  url2=$(echo $2|sed -E 's/([^&]*).*/\1/')
  if [ "$url1" == "$url2" ]
  then
    return 0
  else
    return 1
  fi
}

uri_escape () {
  echo $1 | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g'
}

parse_entry () {
  entry=$(cat $1)
  date=$2

  max_comments=100
  has_two_links=$(echo $entry| grep -E '/.*utm_term=([a-z]*).*utm_term=([a-z]*)'| wc -l)
  if [ "$has_two_links" -lt 1 ] 
  then
    # has one link
    max_comments=1000
    type="ask_hn"
    title=$(echo $entry|sed -E 's/.*Comments:\s[0-9]+">([^<]*).*/\1/')
    commentsurl=$(echo $entry| sed -E 's/.*href="([^"]*)".*/\1/')
    text="..."
    url=$commentsurl
  else
    # has two links
    type=$(echo $entry| sed -E 's/.*utm_term=([a-z]*).*utm_term=([a-z]*).*/\1/')
    title=$(echo $entry|sed -E 's/.*Comments:\s[0-9]+">([^<]*).*/\1/')
    url=$(echo $entry| sed -E 's/.*href="([^"]*)".*href="([^"]*)".*/\1/')
    commentsurl=$(echo $entry| sed -E 's/.*href="([^"]*)".*href="([^"]*)".*/\2/')

    if base_url_identical $url $commentsurl
    then
      max_comments=1000
      text="..."
      url=$commentsurl
    else
      # get univisified text
      text=$(../../../unvisify.bash "$url")
    fi
  fi

  md5id=$(echo $text$url |md5sum |sed -E 's/\s.*//')
  # use curl for comments
  sleep 2
  hnid=$(echo $commentsurl |sed -E 's/.*id=([0-9]*).*/\1/')
  responsivecommentsurl=http://neilmagee.com/project/hn/comments.php?id=$hnid
  comments=$(curl $responsivecommentsurl -L -s| head -c 3000K)

  # remove any CDATA entries
  text=$(echo $text| sed -E 's/<!\[CDATA\[//g')
  text=$(echo $text| sed -E 's/\]\]>//g')
  comments=$(echo $comments| sed -E 's/<!\[CDATA\[//g')
  comments=$(echo $comments| sed -E 's/\]\]>//g')

  # escape &
  url=$(uri_escape "$url")
  title=$(uri_escape "$title")

  # limit size of text
  text=$(echo $text| head -c 3000K)

  echo  "<entry>
  <title>$type $title</title>
  <link href=\"$url\"/>
  <id>urn:hash:md5:$md5id</id>
  <updated>$date</updated>
  <summary type=\"html\"><![CDATA[
  <a href="http://unvis.it/$url">http://unvis.it/$url</a>
  $entry
  $text
  $comments
  ]]></summary>
  </entry>"
}

date=$1

for entry in *
do
  parse_entry $entry "$date"
done
