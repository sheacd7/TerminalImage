#!/bin/bash
# META =========================================================================
# Title: TerminalImage.sh
# Usage: TerminalImage.sh
# Description: Print image in terminal.
# Author: Colin Shea
# Created: 2016-02-21

# TODO
#   command line option for 1 vs 2 rows per line
#   abstract out awk indexing
#   get rows/cols without modifying IFS
#   skip writing to intermediate txt files

imgfile="$1"
txtfile="${imgfile%%.*}.txt"
outfile="${imgfile%%.*}_out.txt"

if [[ ! -f "${txtfile}" ]]; then 
  printf '%s\n' "Converting image to text"
  convert "${imgfile}" txt: > "${txtfile}"
fi

printf '%s\n' "Loading image to buffer"
old_IFS=$IFS
IFS=':,'; read comment cols rows max format < <(head -1 "${txtfile}")
IFS=${old_IFS}
printf '%s:%d, %s:%d\n' "Cols" "${cols}" "Rows" "${rows}" 

# one row per line =============================================================
tail -"$((rows*cols))" "${txtfile}" | \
cut -f 2 -d ' ' | \
tr -d '()' | \
tr ',' ';' | \
awk -v c="$cols" '
{
  j=((NR-1) % c)
  i+=(j==0)
  a[i,j]=$1
  max_NR=NR
}
END {
  r=max_NR/c
  for(i=1; i<=r; i++) {
    str=a[i,0]
    for(j=1; j<c; j++) {
      str=str" "a[i,j]
    }
    print str
  }
}' > "${outfile}"

# apply terminal codes to pixel rgb values
mapfile -t img < "${outfile}"
for row in "${!img[@]}"; do
  printf -v image[$row] '\033[38;2;%sm\u2588' ${img[$row]}
done

# two rows per line ============================================================
# tail -"$((rows*cols))" "${txtfile}" | \
# cut -f 2 -d ' ' | \
# tr -d '()' | \
# tr ',' ';' | \
# awk -v c="$cols" '
# {
#   x=((NR-1) % (2*c))
#   j=2*x
#   x>=c && j-=((2*c)-1)
#   i+=(x==0)
#   a[i,j]=$1
#   max_NR=NR
# }
# END {
#   r=max_NR/(2*c)
#   for(i=1; i<=r; i++) {
#     str=a[i,0]
#     for(j=1; j<(2*c); j++) {
#       str=str" "a[i,j]
#     }
#     print str
#   }
# }' > "${outfile}"
# 
# # apply terminal codes to pixel rgb values
# mapfile -t img < "${outfile}"
# for row in "${!img[@]}"; do
#   printf -v image[$row] '\033[38;2;%s;48;2;%sm\u2580' ${img[$row]}
# done


# print image
printf '%b\n' "${image[@]}"

# scratch ======================================================================

# print with full block per row
# this method is way too slow
#mapfile -s 1 -t pixels < <(cut -f 2 -d ' ' "${txtfile}" | tr -d '()' | tr ',' ';')
#for ((row=0; row<${rows}; row++)); do
#  printf -v image[$row] "\\033[38;2;%sm\\u2588" "${pixels[@]:$((row*cols)):$cols}"
#done
# ==============================================================================

#"\\033[38;2;r;g;b;48;2;r;g;bm\\u2580"

# ImageMagick pixel enumeration: 286,280,255,srgb
#0,0: (255,255,255)  #FFFFFF  white
#1,0: (255,255,255)  #FFFFFF  white

# from hex
#mapfile -s 1 -n $cols -O $row -t < <(cut -f 3 -d ' ' "${img}")
# from rgb
#mapfile -s 1 -n $cols -O $row -t < <(cut -f 2 -d ' ' "${img}" | tr ',()' ';  ' )

# attempts to interleave rows (print 2 rows at once with upper block unicode) ==
#for ((row=0; row<$(( ${rows} - 1 )); row+=2)); do
#  printf -v image[$(($row / 2))] "\\033[38;2;%s;48;2;%sm\\u2580" \
#    "${pixels[@]:$(( $row * $cols)):$cols}" \
#    "${pixels[@]:$(( ($row + 1) * $cols)):$cols}"
#done

# combine alternating runs of length $cols to each row
#for ((row=0; row<$rows; row++)); do
#  arr[$row]=$(paste \
#    <(sed -n $((row*10 + 1)),+4p test.txt) 
#    <(sed -n $((row*10 + 6)),+4p test.txt) )
#done
#printf '%s\n' "${arr[@]}"

# print with half-block per row
#for ((row=0; row<$rows; row++)); do 
#  row1=$((row*cols*2 +1))
#  row2=$((row1 + cols))
#  arr[$row]=$(paste \
#    <(sed -n $row1,+$((cols-1))p $txtfile) \
#    <(sed -n $row2,+$((cols-1))p $txtfile) )
#done
