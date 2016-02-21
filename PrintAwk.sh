#!/bin/bash

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

# reformat text to interleaved odd/even rows
# r1c1, r1c2, r1c3, r2c1, r2c2, r2c3
# r1c1, r2c1, r1c2, r2c2, r1c3, r2c3
tail -"$((rows*cols))" "${txtfile}" | cut -f 2 -d ' ' | tr -d '()' | tr ',' ';' | \
awk -v c="$cols" '
{
  x=((NR-1) % (2*c))
  j=2*x
  x>=c && j-=((2*c)-1)
  i+=(x==0)
  a[i,j]=$1
  max_NR=NR
}
END {
  r=max_NR/(2*c)
  for(i=1; i<=r; i++) {
    str=a[i,0]
    for(j=1; j<(2*c); j++) {
      str=str" "a[i,j]
    }
    print str
  }
}' > "${outfile}"

# apply terminal codes to pixel rgb values
mapfile -t img < "${outfile}"
for row in "${!img[@]}"; do
  printf -v image[$row] '\033[38;2;%s;48;2;%sm\u2580' ${img[$row]}
done
printf '%b\n' "${image[@]}"

# scratch
#    printf "\\033[38;2;%s;48;2;%sm\\u2580", str
#| printf "\\033[38;2;%s;48;2;%sm\\u2580" 

# cols=3
#x  j     i
#0  0  0  1
#1  2  2  1
#2  4  4  1
#3  6  1  1
#4  8  3  1
#5 10  5  1
#         2

# column
# k=((NR-1) % c)

#awk '
# { 
#  for (i=1; i<=NF; i++)  {
#    a[NR,i] = $i
#  }
# }
#NF>p { p = NF }
#END {  
#  for(j=1; j<=p; j++) {
#    str=a[1,j]
#    for(i=2; i<=NR; i++){
#      str=str" "a[i,j];
#    }
#    print str
#  }
#}' file
#

#
#cols=3
#rows=2
#
#NR col row
# 1   1   1
# 2   2   1
# 3   3   1
# 4   1   2
# 5   2   2
# 6   3   2
