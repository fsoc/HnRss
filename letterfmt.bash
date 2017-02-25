#!/bin/bash
# split till entryfiler
cd letters
mkdir -p entries

counter=0
for letter in hnletter*
do
  cat $letter| grep utm_term| sort| uniq| grep -v 'utm_term=data'| grep -v 'utm_term=design'| split -l 1 - entry
  entries=$(find .| grep entry| wc -l)
  if [ "$entries" -gt 0 ]
  then
    # dont parse all letters
    if [ "$counter" -lt 1 ] 
    then
      mkdir -p entries/letter$counter
      mv entry* entries/letter$counter

      date=$1

      cd entries/letter$counter
      ../../../entryfmt.bash "$date"
      cd ../..

    fi
    counter=$((counter + 1))
  fi
done
