#!/bin/bash
# META =========================================================================
# Title: PrintArray.sh
# Usage: PrintArray.sh
# Description: Print image from numpy text file in terminal.
# Author: Colin Shea
# Created: 2016-03-02

# TODO

# DONE
#   support 2-line per row mode
#   convert 8-bit grayscale to rgb values

# input text file is output from numpy.savetxt
textfile="$1"
# command-line arg: rows per line
rpl=${2:-1}

# convert 8-bit grayscale values to rgb (copy value to each channel)
mapfile -t img < <( \
awk -v r="$rpl" '
{
  i=NR
  for (j=1; j<=NF; j++) { 
    a[i,j]=$j";"$j";"$j 
  } 
  maxNF=NF
  maxNR=NR
} 
END { 
  for (i=1; i<=(maxNR); i+=r) { 
    str=""
    for (j=1; j<=maxNF; j++) { 
      for (k=0; k<r; k++) {
        str=str" "a[i+k,j]
      }
    } 
    print str 
  }
}' ${textfile} ) 
#printf '%s\n' "${img[@]}"

# apply terminal codes to pixel rgb values
case $rpl in 
  1) for row in "${!img[@]}"; do 
       printf -v image[$row] '\033[38;2;%sm\u2588' ${img[$row]}; done ;;
  2) for row in "${!img[@]}"; do 
       printf -v image[$row] '\033[38;2;%s;48;2;%sm\u2580' ${img[$row]}; done ;;
  *) echo "Unsupported rows per line: $rpl"; exit ;;
esac
# print image
printf '%b\033[0m\n' "${image[@]}"

# one row per line
# mapfile -t img < <( \
# awk '
# {
#   i=(NR-1)
#   for (j=1; j<=NF; j++) { 
#     a[i,j-1]=$j";"$j";"$j 
#   } 
#   maxNF=NF
#   maxNR=NR
# } 
# END { 
#   for (i=0; i<maxNR; i++) { 
#     str=a[i,0] 
#     for (j=1; j<maxNF; j++) { 
#       str=str" "a[i,j] 
#     } 
#     print str 
#   }
# }' ${textfile} ) 

# print directly from awk with terminal codes
# note: awk will not interpret \u unicode
# awk '
# {
#   i=NR
#   for (j=1; j<=NF; j++) { 
#     a[i,j]=$j";"$j";"$j
#   } 
#   maxNF=NF
#   maxNR=NR
# } 
# END { 
#   for (i=1; i<=maxNR; i++) { 
#     str="\033[38;2;"a[i,1]"m█"
#     for (j=2; j<=maxNF; j++) { 
#       str=str"\033[38;2;"a[i,j]"m█"
#     }
#     print str"\033[0m"
#   }
# }' ${textfile}
