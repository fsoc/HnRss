#!/bin/bash
rm -r letters
mkdir letters

rssfeed="http://us1.campaign-archive2.com/feed?u=faa8eb4ef3a111cef92c4f3d4&id=e505c88a2e"

curl -s -L $rssfeed > feed.xml
csplit -q -f hnletter feed.xml '/<item>/' {*}
mv hnletter* letters

pubDate=$(cat feed.xml |grep pubDate |head -n 2| tail -n 1| sed -E 's/<pubDate>(.*) \+0000<\/pubDate>/\1/')
md5id=$(echo $pubDate |md5sum |sed -E 's/\s.*//')
# dates, we need to parse rfc 2822 to iso 8601 fmt to get real dates
date=$(date --date "$pubDate" +"%Y-%m-%dT%H:%M:%SZ")

echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<feed xmlns=\"http://www.w3.org/2005/Atom\">

<title>HnRss</title>
<link href=\"http://dev.null\"/>
<author>
<name>Anonymous User</name>
</author>
<id>urn:hash:md5:$md5id</id>
<updated>$date</updated>"

./letterfmt.bash $date

echo '</feed>'
