#!/bin/bash
OPTIONS="Snapmirrored Quiesced Broken-off"
select opt in $OPTIONS; do
	if [ "$opt" = "Snapmirrored" ]; then
          echo "STSSP    $opt" > /tmp/readme
        elif [ "$opt" = "Quiesced" ]; then
          echo "STSSP $opt" > /tmp/readme
        elif [ "$opt" = "Broken-off" ]; then
	  echo "STSSP $opt" > /tmp/readme
        else
         clear
         echo bad option
        fi
done
