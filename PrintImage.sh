#!/bin/bash

# test for line endings
#"\\033[38;2;r;g;b;48;2;r;g;bm\\u2580"

# ImageMagick pixel enumeration: 286,280,255,srgb
#0,0: (255,255,255)  #FFFFFF  white
#1,0: (255,255,255)  #FFFFFF  white

# from hex
#mapfile -s 1 -n $cols -O $row -t < <(cut -f 3 -d ' ' "${img}")
# from rgb
#mapfile -s 1 -n $cols -O $row -t < <(cut -f 2 -d ' ' "${img}" | tr ',()' ';  ' )

# read $cols lines to array
# 
#printf -v row "\\033[38;2;%bm\\u2580" "${arr[@]}"

imgfile="$1"
txtfile="${imgfile%%.*}.txt"

if [[ ! -f "${txtfile}" ]]; then 
  printf '%s\n' "Converting image to text"
  convert "${imgfile}" txt: > "${txtfile}"
fi

printf '%s\n' "Loading image to buffer"
mapfile -s 1 -t pixels < <(cut -f 2 -d ' ' "${txtfile}" | tr -d '()' | tr ',' ';')
IFS=':,'; read comment cols rows max format < <(head -1 "${txtfile}")
printf '%s:%d, %s:%d\n' "Cols" "${cols}" "Rows" "${rows}" 
#cols=286
#rows=280

declare -a image 
for ((row=0; row<${rows}; row++)); do
#for ((row=0; row<$(( ${rows} - 1 )); row+=2)); do
  printf -v image[$row] "\\033[38;2;%sm\\u2588" "${pixels[@]:$(($row * $cols)):$cols}"
#  printf -v image[$(($row / 2))] "\\033[38;2;%s;48;2;%sm\\u2580" \
#    "${pixels[@]:$(( $row * $cols)):$cols}" \
#    "${pixels[@]:$(( ($row + 1) * $cols)):$cols}"
done
printf '%b\n' "${image[@]}"

# printf '%b' "\\u2580"
# \u2580   upper half block
# \u2584   lower half block
# \u2588   full block
# \u258c   left  half block
# \u2590   right half block
