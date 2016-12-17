#!/bin/bash
rm -r letters
mkdir letters

rssfeed="http://us1.campaign-archive2.com/feed?u=faa8eb4ef3a111cef92c4f3d4&id=e505c88a2e"

curl -s -L $rssfeed > feed.xml
csplit -q -f hnletter feed.xml '/<item>/' {*}
mv hnletter* letters

uuid=$(uuidgen)
date=$(date +"%Y-%m-%dT%H:%M:%SZ")

echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<feed xmlns=\"http://www.w3.org/2005/Atom\">

<title>HnRss</title>
<link href=\"http://dev.null\"/>
<author>
<name>Anonymous User</name>
</author>
<id>urn:uuid:$uuid</id>
<updated>$date</updated>"

./letterfmt.bash

echo '</feed>'
