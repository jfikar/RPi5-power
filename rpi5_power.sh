#!/bin/sh
SECONDS=50
BOTH=$(mktemp)
CURRENT=$(mktemp)
TENSION=$(mktemp)
CONSUMPTION=$(mktemp)
for i in $(seq 1 ${SECONDS})
do
	sleep 1
	vcgencmd pmic_read_adc > ${BOTH}
	cat ${BOTH} | grep current | awk '{print substr($2, 1, length($2)-1)}' | sed 's/.*=//g'            > ${CURRENT}
	cat ${BOTH} | grep volt    | awk '{print substr($2, 1, length($2)-1)}' | sed 's/.*=//g' | head -12 > ${TENSION}
	paste ${CURRENT} ${TENSION}| awk '{sum+=$1*$2}END{print sum}' >> ${CONSUMPTION}
	rm ${CURRENT} ${TENSION} ${BOTH}
done
cat ${CONSUMPTION} | awk '{sumX+=+$1;sumX2+=(($1)^2)}END{if (NR>1) printf "Average_power_consumption= %.3f +/- %.3f W\n", sumX/(NR)*1.1451+0.5879, sqrt((sumX2-sumX^2/NR)/(NR-1)/NR)*1.1451}'
rm ${CONSUMPTION}
