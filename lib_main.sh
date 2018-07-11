#!/bin/bash
#
# Version 0.01
#
#
# 06/2018, Alexey Tarasenko, atarasenko@mail.ru
#
#

# return Position of Value in String with Values splited Delimiter
#val2pos() {
# clear space and new line in front and end of string
#trim() {
# decode string of Capacity to Numeric of base in KB
#str2KB() {
# decode Numeric of base in KB to string of Capacity
#KB2str() {
#b2kb() {
#kb2gb() {
#replace Tab to Spaces in file $1 to file $2
#tab2spaces() {


# return Position of Value in String with Values splited Delimiter
val2pos() {
    local string="$1"
    local delimiter="$2"
    local value="$3"
    local index=1
    if [ -n "$string" ]; then
        local part
        while read -d "$delimiter" part; do
            if [[ "$part" == "$value" ]]; then echo -n $index; break; fi
            index=$(($index+1))
        done <<< "$string"
    fi
}

                                                                        
# clear space and new line in front and end of string
trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    echo -n "$var"
}


# decode string of Capacity to Numeric of base in KB
# Only Num bytes, B/b bytes, K/k/KB/Kb/kb kilobytes, M/m/MB/Mb/mb megabytes, G/g/GB/Gb/gb gigabytes, T/t/TB/Tb/tb terabytes
str2KB() {
    local str="$1"
    local res=0
    str=${str//" "/""}
    str=$(echo "$str" | tr '[:lower:]' '[:upper:]')
    
    local var=""
    local mul=1
    local num="0"
    
    if [[ "$num" == "0" ]]; then
	# Bytes
	# without chars
	var=`echo -n "$str" | grep "^\([0-9]\|\.\)\+$"`
	if [[ "$var" != "" ]]; then mul="1"; num="$str"; fi
	# chars 'B'
	var=`echo -n "$str" | grep "^\([0-9]\|\.\)\+B$"`
	if [[ "$var" != "" ]]; then mul="1"; num="${str%B}"; fi
    
	# base as Kilobytes 
	if [[ "$num" != "0" ]]; then
	    num=$( echo "scale=0;${num}/1024" | bc -l )
	    #if [[ $num -lt 512 ]]; then num="0"; else num="1"; fi
	fi
    fi
    
    if [[ "$num" == "0" ]]; then
	# Kilobytes
	# chars 'K'
	var=`echo -n "$str" | grep "^\([0-9]\|\.\)\+K$"`
	if [[ "$var" != "" ]]; then mul="1"; num="${str%K}"; fi
	# chars 'KB'
	var=`echo -n "$str" | grep "^\([0-9]\|\.\)\+KB$"`
	if [[ "$var" != "" ]]; then mul="1"; num="${str%KB}"; fi
    fi
    
    if [[ "$num" == "0" ]]; then
	# Megabytes
	# chars 'M'
	var=`echo -n "$str" | grep "^\([0-9]\|\.\)\+M$"`
	if [[ "$var" != "" ]]; then mul="1024"; num="${str%M}"; fi
	# chars 'MB'
	var=`echo -n "$str" | grep "^\([0-9]\|\.\)\+MB$"`
	if [[ "$var" != "" ]]; then mul="1024"; num="${str%MB}"; fi
    fi

    if [[ "$num" == "0" ]]; then
	# Gigabytes
	# chars 'G'
	var=`echo -n "$str" | grep "^\([0-9]\|\.\)\+G$"`
	if [[ "$var" != "" ]]; then mul="1024*1024"; num="${str%G}"; fi
	# chars 'GB'
	var=`echo -n "$str" | grep "^\([0-9]\|\.\)\+GB$"`
	if [[ "$var" != "" ]]; then mul="1024*1024"; num="${str%GB}"; fi
    fi

    if [[ "$num" == "0" ]]; then
	# Terabytes
	# chars 'T'
	var=`echo -n "$str" | grep "^\([0-9]\|\.\)\+T$"`
	if [[ "$var" != "" ]]; then mul="1024*1024*1024"; num="${str%T}"; fi
	# chars 'TB'
	var=`echo -n "$str" | grep "^\([0-9]\|\.\)\+TB$"`
	if [[ "$var" != "" ]]; then mul="1024*1024*1024"; num="${str%TB}"; fi
    fi

    res=`echo "scale=0;(${num}*${mul})/1" | bc -l`
    echo -n "$res"
}


# decode Numeric of base in KB to string of Capacity
KB2str() {
    local sumkb="$1"
    
    local outtxt="$sumkb KB"
    local sumMB=`echo "$sumkb/1024" | bc -l | grep -v "^\."` 
    if [[ "$sumMB" != "" ]]; then outtxt=$( printf "%7.2f %s" $sumMB "MB" ); fi
    if [[ "$sumMB" != "" ]]
    then
    	local sumGB=`echo "$sumMB/1024" | bc -l | grep -v "^\."`
        if [[ "$sumGB" != "" ]]; then outtxt=$( printf "%7.2f %s" $sumGB "GB" ); fi
        if [[ "$sumGB" != "" ]]
        then
    	    local sumTB=`echo "$sumGB/1024" | bc -l | grep -v "^\."`
    	    if [[ "$sumTB" != "" ]]; then outtxt=$( printf "%7.2f %s" $sumTB "TB" ); fi
    	fi
    fi 
    outtxt=$( trim "$outtxt" )
    echo -n "$outtxt"
}


#vol_size=$( b2kb $vol_size 0 ); vol_size=${vol_size:0:(${#vol_size}-1)}
b2kb() {
    local value=$1
    local fix=$2
    local mul=1
    local div=1
    local a=0
    
    for ((a=0; a < $fix; a++))
    do
	mul=$(($mul*10))	
    done
    div=$(($div*1024))
    
    echo $(($value*mul/$div)) | sed "s/\([0-9]\{$fix\}$\)/.\1/"
}


#vol_size=$( value64bit $valH $valL ); vol_size=$( kb2gb $vol_size 2 ); vol_size="${vol_size}GB"
kb2gb() {
    local value=$1
    local fix=$2
    local mul=1
    local div=1
    local a=0
    
    for ((a=0; a < $fix; a++))
    do
	mul=$(($mul*10))	
    done
    div=$(($div*1024*1024))
    
    echo $(($value*mul/$div)) | sed "s/\([0-9]\{$fix\}$\)/.\1/"
}


#replace Tab to Spaces in file $1 to file $2
tab2spaces() {
    local infile=$1 
    local outfile=$2
    local chartab=`echo -n -e "\t"`
    
    echo -n > $outfile

    while read
    do
        local i=0
	local ii=0
	local str=${REPLY}
	local strlen=${#str}
	for ((i=0; i<$strlen; i++))
	do
	    local char=${str:$i:1}
	    local delta=1
	    if [[ "$char" == "$chartab" ]]
	    then
		let "delta = 8 - ($ii % 8)"
		char=""
		local j=0
		for ((j=0; j<$delta; j++))
		do
		    char="${char} "
		done
	    fi
	    ii=$(( $ii + $delta ))
	    echo -n "$char" >> $outfile
	done
	echo "" >> $outfile
    done < $infile
}

