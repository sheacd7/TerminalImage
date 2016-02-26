#!/bin/bash
# META =========================================================================
# Title: TerminalImage.sh
# Usage: TerminalImage.sh
# Description: Print image in terminal.
# Author: Colin Shea
# Created: 2016-02-21

# TODO
#   skip writing to intermediate txt file for image conversion
#   preserve border (reset fg/bg to black)

# DONE
#   command line option for 1 vs 2 rows per line
#   abstract out awk indexing
#   skip one of two intermediate text files
#   get rows/cols without modifying IFS

imgfile="$1"
txtfile="${imgfile%%.*}.txt"
#outfile="${imgfile%%.*}_out.txt"

if [[ ! -f "${txtfile}" ]]; then 
  printf '%s\n' "Converting image to text"
  convert "${imgfile}" txt: > "${txtfile}"
fi

printf '%s\n' "Loading image to buffer"
read -r -a header < <(head -1 "${txtfile}")
read -r cols rows max format < <(printf '%s\n' "${header[4]//,/ }")
printf '%s:%d, %s:%d\n' "Cols" "${cols}" "Rows" "${rows}" 

# command-line arg: rows per line
rpl=$2

# map indices of pixel stream to cols * lines array
mapfile -t img < <( \
tail -"$((rows*cols))" "${txtfile}" | \
cut -f 2 -d ' ' | \
tr -d '()' | \
tr ',' ';' | \
awk -v c="$cols" -v r="$rpl" '
BEGIN {
  row=-1
  i=0
}
{
  col=(NR-1) % c
  (col==0) && row++
  (row>=r) && i++ 
  (row>=r) && row=0
  j=(col*r) + row 
  a[i,j]=$1
  max_NR=NR
}
END {
  rmax=max_NR/(c*r)
  for(i=0; i<rmax; i++) {
    str=a[i,0]
    for(j=1; j<(c*r); j++) {
      str=str" "a[i,j]
    }
    print str
  }
}
' )
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
printf '%b\n' "${image[@]}"


