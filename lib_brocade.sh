#!/bin/bash
#
# Version 0.01
#
#
# 06/2018, Alexey Tarasenko, atarasenko@mail.ru
#
#

# recompile multilines to one line by key with Tab delimiter each word
#recomp() {
# Type of Brocade switch by Brocade_ID
#swtype() {


# recompile multilines to one line by key with Tab delimiter each word
#from:
# KEY	Name	A B
#		C D
#to:
# KEY	Name	A; B; C; D
recomp() {
    local fout="$1"
    local key="$2"
    local index=0
    while read line; do
	arrstr[$index]="$line"
        index=$(($index+1))
    done < $fout

    echo -n > $fout

    local buf=""
    local s=""
    local a=0;
    for ((a=0; a < ${#arrstr[*]}; a++))
    do
        s=$( trim "${arrstr[$a]}" )
        if [[ ${s:0:${#key}} == $key ]]
        then
    	    if [[ $buf != ""  ]]; then echo "$buf" | tr ' ' '\t' | tr -s '\t'  >> $fout; fi
    	    buf=$( trim "$s" )
        else
    	    local tmp=( $buf )
    	    if [[ ${#tmp[@]} -gt 2 ]]; then buf="$buf; $s"; else buf="$buf $s"; fi
        fi
    done
    if [[ $buf != ""  ]]; then echo "$buf" | tr ' ' '\t' | tr -s '\t'  >> $fout; fi
    unset arrstr
}


# Type of Brocade switch by Brocade_ID
swtype() {
    local var="$*"
    declare -a matrix
    matrix[1]="Brocade 1000"
    matrix[2]="Brocade 2010"
    matrix[3]="Brocade 2400"
    matrix[4]="Brocade 20x0"
    matrix[5]="Brocade 22x0"
    matrix[6]="Brocade 2800"
    matrix[7]="Brocade 2000"
    matrix[9]="Brocade 3800"
    matrix[10]="Brocade 12000"
    matrix[12]="Brocade 3900"
    matrix[16]="Brocade 3200"
    matrix[17]="Brocade 3800VL"
    matrix[18]="Brocade 3000"
    matrix[21]="Brocade 24000"
    matrix[22]="Brocade 3016"
    matrix[26]="Brocade 3850"
    matrix[27]="Brocade 3250"
    matrix[29]="Brocade 4012 Embedded"
    matrix[32]="Brocade 4100"
    matrix[33]="Brocade 3014"
    matrix[34]="Brocade 200E"
    matrix[37]="Brocade 4020 Embedded"
    matrix[38]="Brocade 7420 SAN Router"
    matrix[40]="Brocade FCR Front Domain"
    matrix[41]="Brocade FCR Xlate Domain"
    matrix[42]="Brocade 48000 Director"
    matrix[43]="Brocade 4024 Embedded"
    matrix[44]="Brocade 4900"
    matrix[45]="Brocade 4016 Embedded"
    matrix[46]="Brocade 7500"
    matrix[51]="Brocade 4018 Embedded"
    matrix[55]="Brocade 7600"
    matrix[58]="Brocade 5000"
    matrix[61]="Brocade 4424 Embedded"
    matrix[62]="Brocade DCX Backbone"
    matrix[64]="Brocade 5300"
    matrix[66]="Brocade 5100"
    matrix[67]="Brocade Encryption Switch"
    matrix[69]="Brocade 5410"
    matrix[70]="Brocade 5410 Embedded"
    matrix[71]="Brocade 300"
    matrix[72]="Brocade 5480 Embedded"
    matrix[73]="Brocade 5470 Embedded"
    matrix[75]="Brocade 5424 Embedded"
    matrix[76]="Brocade 8000"
    matrix[77]="Brocade DCX-4S"
    matrix[83]="Brocade 7800"
    matrix[86]="Brocade 5450 Embedded"
    matrix[87]="Brocade 5460 Embedded"
    matrix[90]="Brocade 8470 Embedded"
    matrix[92]="Brocade VA-40FC"
    matrix[95]="Brocade VDX 6720-24 Data Center"
    matrix[96]="Brocade VDX 6730-32 Data Center"
    matrix[97]="Brocade VDX 6720-60 Data Center"
    matrix[98]="Brocade VDX 6730-76 Data Center"
    matrix[108]="Dell M8428-k FCoE Embedded"
    matrix[109]="Brocade 6510"
    matrix[116]="Brocade VDX 6710 Data Center"
    matrix[117]="Brocade 6547 Embedded"
    matrix[118]="Brocade 6505"
    matrix[120]="Brocade DCX8510-8 Backbone"
    matrix[121]="Brocade DCX8510-4 Backbone"
    matrix[133]="Brocade 6520"

    #if [[ ${sw_type:(-2)}==".0" ]]; then sw_type=${sw_type/%".0"/""}; fi
    var=${var%.*}
    local res=${matrix[$var]}
    if [[ "$res" == "" ]]; then echo -n "$var"; else echo -n "$res"; fi
    unset matrix
}

