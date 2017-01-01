#!/bin/bash

uri_escape () {
  echo $1 | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g'
}

parse_entry () {
  entry=$(cat $1)
  letterdate=$2

  uuid=$(uuidgen)
  has_two_links=$(echo $entry| grep -E '/.*utm_term=([a-z]*).*utm_term=([a-z]*)'| wc -l)
  if [ "$has_two_links" -lt 1 ] 
  then
    # has one link
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
    # use curl
    text=$(../../../unvisify.bash "$url")
  fi

  # use curl
  comments=$(curl $commentsurl -L -s| head -n 100)

  # remove any CDATA entries
  text=$(echo $text| sed -E 's/<!\[CDATA\[//g')
  text=$(echo $text| sed -E 's/\]\]>//g')
  comments=$(echo $comments| sed -E 's/<!\[CDATA\[//g')
  comments=$(echo $comments| sed -E 's/\]\]>//g')

  # escape &
  url=$(uri_escape "$url")
  title=$(uri_escape "$title")

  # dates, we need to parse rfc 2822 to iso 8601 fmt to get real dates
  date=$(date +"%Y-%m-%dT%H:%M:%SZ")

  # limit size of text
  text=$(echo $text| head -c 3000K)

  echo  "<entry>
  <title>$type $title</title>
  <link href=\"$url\"/>
  <id>urn:uuid:$uuid</id>
  <updated>$date</updated>
  <summary type=\"html\"><![CDATA[
  $entry
  $text
  $entry
  $comments
  ]]></summary>
  </entry>"
}

letterdate=$1

for entry in *
do
  parse_entry $entry "$letterdate" #>> ../../../newhnfeed.xml
done
