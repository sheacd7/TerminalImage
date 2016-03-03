#!/bin/bash
# META =========================================================================
# Title: PrintArray.sh
# Usage: PrintArray.sh
# Description: Print image from numpy text file in terminal.
# Author: Colin Shea
# Created: 2016-03-02

# TODO
#   support 2-line per row mode

# DONE
#   convert 8-bit grayscale to rgb values

# input text file is output from numpy.savetxt
textfile="$1"

# convert 8-bit grayscale values to rgb (copy value to each channel)
mapfile -t img < <( \
awk '
{
  i=(NR-1)
  for (j=1; j<=NF; j++) { 
    a[i,j-1]=$j","$j","$j 
  } 
  maxNF=NF
  maxNR=NR
} 
END { 
  for (i=0; i<maxNR; i++) { 
    str=a[i,0] 
    for (j=1; j<maxNF; j++) { 
      str=str" "a[i,j] 
    } 
    print str 
  }
}' ${textfile} | \
tr ',' ';' )
#printf '%s\n' "${img[@]}"

# apply terminal codes to pixel rgb values
for row in "${!img[@]}"; do 
  printf -v image[$row] '\033[38;2;%sm\u2588' ${img[$row]}
done

# print image
printf '%b\033[0m\n' "${image[@]}"
