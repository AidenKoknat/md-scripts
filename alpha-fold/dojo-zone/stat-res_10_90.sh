#!/bin/bash
for res in *.dat
do
{
res1=${res%.*}
echo $res1
python3 stat-res_10_90.py $res1 >> stat-res_10_90.boxplot
}
done
