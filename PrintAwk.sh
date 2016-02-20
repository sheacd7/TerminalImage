awk '
{ 
  for (i=1; i<=NF; i++)  {
    a[NR,i] = $i
  }
}
NF>p { p = NF }
END {  
  for(j=1; j<=p; j++) {
    str=a[1,j]
    for(i=2; i<=NR; i++){
      str=str" "a[i,j];
    }
    print str
  }
}' file



# cols=5
# rows=6
i=1:30

1:rows/2
1:cols

 1;6   2;7   3;8   4;9   5;10
11;16 12;17 13;18 14;19 15;20


r1c1;r2c1 r1c2;r2c2

for i=1; i<=rows; i+=2
  for j=1; j<=cols; j++
  a[$i] a[$i]

