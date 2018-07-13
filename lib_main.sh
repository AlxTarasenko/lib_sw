#!/bin/bash
#
# Version 0.51
#
#
#str2B()	decode string of Capacity/Speed to Numeric with base in B/b, may override multipler $2=[1024|1000], IEEE 1541/IEC 60027-2
#B2str()	decode Numeric to string of Capacity/Speed, may override with base in $2=[byte|bit|byte_s|bit_s] and multipler $3=[1024|1000], IEEE 1541/IEC 60027-2
#str2KB()	decode string of Capacity to Numeric of base in KB
#KB2str()	decode Numeric of base in KB to string of Capacity
#b2kb()		convert Numeric bytes to Numeric kilibytes, base 1024
#kb2gb()	convert Numeric kilobytes to Numeric gigabytes, base 1024
#tab2spaces()	replace Tab to Spaces in file $1 to file $2, with preserve format
#val2pos()	return Position of Value in String with Values splited Delimiter
#trim()		clear space and new line in front and end of string
#
#
# 06/2018, Alexey Tarasenko, atarasenko@mail.ru
#


# decode string of Capacity/Speed to Numeric with base in B/b, may override multipler $2=[1024|1000], IEEE 1541/IEC 60027-2
str2B() {
    #default values
    local mul=1
    local mulOver=0
    local grad=""
    local gradOver=""
    local base="byte"
    local str="0"
    local suffix=""
    local res=0
    local gradchar=""

    #only digits, var=${var//[^0-9]} OR `echo "$var" | sed 's/[^0-9]//g'`
    if [[ -n "$1" ]]; then str="$1"; str=${str// }; grad=${str//[^A-Za-z]}; str=${str//[^0-9.]}; fi 
    gradOver=$(echo "$grad" | tr '[:lower:]' '[:upper:]')
    if [[ -n "$2" ]] && [[ "$2" == "1024" ]]; then mulOver=1024; fi
    if [[ -n "$2" ]] && [[ "$2" == "1000" ]]; then mulOver=1000; fi

    if [[ -z "$str" ]] || [[ "$str" == "." ]]; then str="0"; fi

    gradchar=${grad//[^b]}
    if [[ "$gradchar" == "b" ]]; then base="bit"; fi

    gradchar=${grad//[^s]}
    if [[ "$gradchar" == "s" ]] && [[ "$base" == "byte" ]]; then base="byte_s"; fi
    if [[ "$gradchar" == "s" ]] && [[ "$base" == "bit" ]]; then base="bit_s"; fi

    grad=${grad//[PSps]}

    local let mulKi=1024
    local let mulK=1000
    if [[ $mulOver -eq 0 ]]; then
	#if [[ "$grad" == "B" ]]; then mul=1; fi
	if [[ "$grad" == "KiB" ]] || [[ "$grad" == "Kib" ]] || [[ "$grad" == "kib" ]] || [[ "$grad" == "kiB" ]]; then let mul=$mulKi; fi
	if [[ "$grad" == "MiB" ]] || [[ "$grad" == "Mib" ]] || [[ "$grad" == "mib" ]] || [[ "$grad" == "miB" ]]; then let mul=$mulKi*$mulKi; fi
	if [[ "$grad" == "GiB" ]] || [[ "$grad" == "Gib" ]] || [[ "$grad" == "gib" ]] || [[ "$grad" == "giB" ]]; then let mul=$mulKi*$mulKi*$mulKi; fi
	if [[ "$grad" == "TiB" ]] || [[ "$grad" == "Tib" ]] || [[ "$grad" == "tib" ]] || [[ "$grad" == "tiB" ]]; then let mul=$mulKi*$mulKi*$mulKi*$mulKi; fi
	#if [[ "$grad" == "b" ]]; then mul=1; fi
	if [[ "$grad" == "KB" ]] || [[ "$grad" == "Kb" ]] || [[ "$grad" == "kb" ]] || [[ "$grad" == "kB" ]]; then let mul=$mulK; fi
	if [[ "$grad" == "MB" ]] || [[ "$grad" == "Mb" ]] || [[ "$grad" == "mb" ]] || [[ "$grad" == "mB" ]]; then let mul=$mulK*$mulK; fi
	if [[ "$grad" == "GB" ]] || [[ "$grad" == "Gb" ]] || [[ "$grad" == "gb" ]] || [[ "$grad" == "gB" ]]; then let mul=$mulK*$mulK*$mulK; fi
	if [[ "$grad" == "TB" ]] || [[ "$grad" == "Tb" ]] || [[ "$grad" == "tb" ]] || [[ "$grad" == "tB" ]]; then let mul=$mulK*$mulK*$mulK*$mulK; fi
    else
	#if [[ "$grad" == "B" ]]; then mul=1; fi
	if [[ "$gradOver" == "KIB" ]] || [[ "$gradOver" == "KB" ]] || [[ "$gradOver" == "KIBPS" ]] || [[ "$gradOver" == "KBPS" ]]; then let mul=$mulOver; fi
	if [[ "$gradOver" == "MIB" ]] || [[ "$gradOver" == "MB" ]] || [[ "$gradOver" == "MIBPS" ]] || [[ "$gradOver" == "MBPS" ]]; then let mul=$mulOver*$mulOver; fi
	if [[ "$gradOver" == "GIB" ]] || [[ "$gradOver" == "GB" ]] || [[ "$gradOver" == "GIBPS" ]] || [[ "$gradOver" == "GBPS" ]]; then let mul=$mulOver*$mulOver*$mulOver; fi
	if [[ "$gradOver" == "TIB" ]] || [[ "$gradOver" == "TB" ]] || [[ "$gradOver" == "TIBPS" ]] || [[ "$gradOver" == "TBPS" ]]; then let mul=$mulOver*$mulOver*$mulOver*$mulOver; fi
    fi

    res=`echo "scale=0;(${str}*${mul})/1" | bc -l`
    echo -n "$res"
}


# decode Numeric to string of Capacity/Speed, may override with base in $2=[byte|bit|byte_s|bit_s] and multipler $3=[1024|1000], IEEE 1541/IEC 60027-2
B2str() {
    #default values
    local mul=1024
    local base="byte"
    local sumB=0
    local suffix=""

    #only digits, var=${var//[^0-9]} OR `echo "$var" | sed 's/[^0-9]//g'`
    if [[ -n "$1" ]]; then sumB="$1"; sumB=${sumB//[^0-9]}; fi 
    if [[ -n "$2" ]] && [[ "$2" == "bit" ]]; then base="bit"; fi
    if [[ -n "$3" ]] && [[ "$3" == "1000" ]]; then mul=1000; fi
    
    if [[ "$base" == "byte" ]]; then
	if [[ $mul -eq 1024 ]]; then suffix=(B KiB MiB GiB TiB); fi
	if [[ $mul -eq 1000 ]]; then suffix=(B KB MB GB TB); fi
    fi
    if [[ "$base" == "bit" ]]; then
	if [[ $mul -eq 1024 ]]; then suffix=(b Kib Mib Gib Tib); fi
	if [[ $mul -eq 1000 ]]; then suffix=(b Kb Mb Gb Tb); fi
    fi
    if [[ "$base" == "byte_s" ]]; then
	if [[ $mul -eq 1024 ]]; then suffix=(Bps KiBps MiBps GiBps TiBps); fi
	if [[ $mul -eq 1000 ]]; then suffix=(Bps KBps MBps GBps TBps); fi
    fi
    if [[ "$base" == "bit_s" ]]; then
	if [[ $mul -eq 1024 ]]; then suffix=(bps Kibps Mibps Gibps Tibps); fi
	if [[ $mul -eq 1000 ]]; then suffix=(bps Kbps Mbps Gbps Tbps); fi
    fi

    local outtxt="$sumB ${suffix[0]}"

    if [[ $sumB -gt 0 ]]
    then
	
	local sumKB=`echo "$sumB/$mul" | bc -l | grep -v "^\."` 
	if [[ -n "$sumKB" ]]; then outtxt=$( printf "%7.2f %s" $sumKB "${suffix[1]}" ); fi
	if [[ -n "$sumKB" ]]
	then
	    
	    local sumMB=`echo "$sumKB/$mul" | bc -l | grep -v "^\."` 
	    if [[ -n "$sumMB" ]]; then outtxt=$( printf "%7.2f %s" $sumMB "${suffix[2]}" ); fi
	    if [[ -n "$sumMB" ]]
	    then
    		
    		local sumGB=`echo "$sumMB/$mul" | bc -l | grep -v "^\."`
    		if [[ -n "$sumGB" ]]; then outtxt=$( printf "%7.2f %s" $sumGB "${suffix[3]}" ); fi
    		if [[ -n "$sumGB" ]]
    		then
    		    
    		    local sumTB=`echo "$sumGB/$mul" | bc -l | grep -v "^\."`
    		    if [[ -n "$sumTB" ]]; then outtxt=$( printf "%7.2f %s" $sumTB "${suffix[4]}" ); fi
    		fi
	    fi
	fi
    fi
    outtxt=$( trim "$outtxt" )
    echo -n "$outtxt"
}


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
	if [[ -n "$var" ]]; then mul="1"; num="$str"; fi
	# chars 'B'
	var=`echo -n "$str" | grep "^\([0-9]\|\.\)\+B$"`
	if [[ -n "$var" ]]; then mul="1"; num="${str%B}"; fi
    
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
	if [[ -n "$var" ]]; then mul="1"; num="${str%K}"; fi
	# chars 'KB'
	var=`echo -n "$str" | grep "^\([0-9]\|\.\)\+KB$"`
	if [[ -n "$var" ]]; then mul="1"; num="${str%KB}"; fi
    fi
    
    if [[ "$num" == "0" ]]; then
	# Megabytes
	# chars 'M'
	var=`echo -n "$str" | grep "^\([0-9]\|\.\)\+M$"`
	if [[ -n "$var" ]]; then mul="1024"; num="${str%M}"; fi
	# chars 'MB'
	var=`echo -n "$str" | grep "^\([0-9]\|\.\)\+MB$"`
	if [[ -n "$var" ]]; then mul="1024"; num="${str%MB}"; fi
    fi

    if [[ "$num" == "0" ]]; then
	# Gigabytes
	# chars 'G'
	var=`echo -n "$str" | grep "^\([0-9]\|\.\)\+G$"`
	if [[ -n "$var" ]]; then mul="1024*1024"; num="${str%G}"; fi
	# chars 'GB'
	var=`echo -n "$str" | grep "^\([0-9]\|\.\)\+GB$"`
	if [[ -n "$var" ]]; then mul="1024*1024"; num="${str%GB}"; fi
    fi

    if [[ "$num" == "0" ]]; then
	# Terabytes
	# chars 'T'
	var=`echo -n "$str" | grep "^\([0-9]\|\.\)\+T$"`
	if [[ -n "$var" ]]; then mul="1024*1024*1024"; num="${str%T}"; fi
	# chars 'TB'
	var=`echo -n "$str" | grep "^\([0-9]\|\.\)\+TB$"`
	if [[ -n "$var" ]]; then mul="1024*1024*1024"; num="${str%TB}"; fi
    fi

    res=`echo "scale=0;(${num}*${mul})/1" | bc -l`
    echo -n "$res"
}


# decode Numeric of base in KB to string of Capacity
KB2str() {
    local sumKB="$1"
    local outtxt="$sumKB KB"
    local sumMB=`echo "$sumKB/1024" | bc -l | grep -v "^\."` 
    if [[ -n "$sumMB" ]]; then outtxt=$( printf "%7.2f %s" $sumMB "MB" ); fi
    if [[ -n "$sumMB" ]]
    then
	local sumGB=`echo "$sumMB/1024" | bc -l | grep -v "^\."` 
	if [[ -n "$sumGB" ]]; then outtxt=$( printf "%7.2f %s" $sumGB "GB" ); fi
	if [[ -n "$sumGB" ]]
	then
    	    local sumTB=`echo "$sumGB/1024" | bc -l | grep -v "^\."`
    	    if [[ -n "$sumTB" ]]; then outtxt=$( printf "%7.2f %s" $sumTB "TB" ); fi
	fi
    fi
    outtxt=$( trim "$outtxt" )
    echo -n "$outtxt"
}


# convert Numeric bytes to Numeric kilibytes, base 1024
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


# convert Numeric kilobytes to Numeric gigabytes, base 1024
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


#replace Tab to Spaces in file $1 to file $2, with preserve format
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


