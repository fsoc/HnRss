# HnRss
Transforms the curated hackernewsletter into a fulltext atom feed including comments. 

I want to easily browse and mark read/unread on individual articles, while not needing to exit my Atom reader 

## Design principles
Wanted to test a simple way of building an small application
* No dependecies except standard linux tools
* No build chains, version managers or package repositories
* Data used between steps in logic is left as plain text files for debugging purposes

## Run
    ./main.bash > hnfeed.xml
    curl -F "hnfeed.xml=@hnfeed.xml" "https://usr:pwd@neocities.org/api/upload"

## Size Limitations
Due to limits in rss readers the size is kept down for every post
* Only formats the latest newsletter
* Only the first 100 lines of comments
* Cuts of text at 3000KiB

