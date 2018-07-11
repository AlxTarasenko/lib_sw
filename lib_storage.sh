#!/bin/bash
#
# Version 0.01
#
#
# 06/2018, Alexey Tarasenko, atarasenko@mail.ru
#
#

# for DotHill (P2000, DS2200)
#tableconv() {
# for NetApp
#value64bit() {
# for Stor2RRD
#getpart() {


# for DotHill (P2000, DS2200)
tableconv() {
    #tableconv $Ftmp "Vdisk;Name;Size;WWN"
    local file="$1"
    local headlst="$2"
    local header=(${headlst//";"/" "})
    local str_len=`grep "\-\-\-\-\-\-\-\-\-\-" $file | wc -c`
    str_len=$(($str_len-1))
    grep "\-\-\-\-\-\-\-\-\-\-" -B 100 $file  | head -n -1 > "$file.head"
    grep "\-\-\-\-\-\-\-\-\-\-" -A 1000 $file | tail -n +2 > "$file.data"

    echo -n "" > "$file.result"
    #echo "StrLen: $str_len" >> "$file.result"

    local index=0
    while read 
    do
	headline[$index]=${REPLY}
	#echo "Head line: ${headline[$index]}" >> "$file.result"
        index=$(($index+1))
    done < "$file.head"
    
    local a=0
    local b=0
    local c=0
    local d=0
    local headwrd=""
    local headwrdlen=0
    local substr=""
    local subchar=""
    declare -a headstr
    declare -a headstart
    declare -a headend
        
    # Proccessing Head for find Line:Start:End of ValueName
    #echo "Head lines: ${#headline[*]}" >> "$file.result"
    for ((a=0; a < ${#header[*]}; a++))
    do
	local seached=0
	headwrd=${header[$a]}
	headwrd=${headwrd//"_"/" "}
	headwrdlen=${#headwrd}

	#printf "id:%d name:\"%s\" len:%d\n" $a "$headwrd" $headwrdlen >> "$file.result"
        for ((b=0; b < ${#headline[*]}; b++))
	do
	    headstr[$a]=$b
	    local headstrlen=${#headline[$b]}
	    local scanend=$(($headstrlen-$headwrdlen+1))
	
	    #printf "istr:%d str:\"%s\" len:%d end:%d\n" $b "${headline[$b]}" $headstrlen $scanend >> "$file.result"
	    for ((c=0; c < $scanend; c++))
	    do
		substr=${headline[$b]:$c:$headwrdlen}
		if [[ "$substr" ==  "$headwrd" ]] 
		then 
		    headstart[$a]=$c
		    headend[$a]=$(($c+$headwrdlen-1))
		    # borders of ColumnName, start and end as started 0 index of string
		    #printf "id:%d name:\"%s\" l:%d s:%d e:%d\n" $a "$headwrd" ${headstr[$a]} ${headstart[$a]} ${headend[$a]} >> "$file.result"
		    for ((d=$((${headend[$a]}+1)); d < $headstrlen; d++))
		    do
			    subchar=${headline[$b]:$d:1}
			    if [[ "$subchar" == " " ]]
			    then
				headend[$a]=$((${headend[$a]}+1))
			    else
				break
			    fi
		    done
		    # if last in line, set length as header line "----------"
		    if [[ $d == $headstrlen ]]; then headend[$a]=$(($str_len-1)); fi
		    
		    #printf "id:%d name:\"%s\" l:%d s:%d e:%d\n" $a "$headwrd" ${headstr[$a]} ${headstart[$a]} ${headend[$a]} >> "$file.result"
		    seached=1
		    break
		fi
		#printf "sub:\"%s\" seach:\"%s\"\n" "$substr" "$headwrd" >> "$file.result"
	    done
	    # if find, not need proccess next lines
	    if [[ $seached == 1 ]]; then break; fi
	done
        # If NOT find, unset header element
        if [[ $seached == 0 ]]; then unset header[$a]; fi
    done

    index=0
    while read 
    do
	dataline[$index]=${REPLY}
	echo "Data line: ${dataline[$index]}" >> "$file.result"
        index=$(($index+1))
    done < "$file.data"
        

    #echo "Proccess Data lines: ${#dataline[*]} Each: ${#headline[*]}" >> "$file.result"
    echo -n > "$file"
    for (( b=0; b < ${#dataline[*]}; b=$(($b+${#headline[*]})) ))
    do
        local datastr=""
        for ((a=0; a < ${#header[*]}; a++))
	do
	    #string id with shift
	    c=$(($b+${headstr[$a]}))
	    #param length
	    d=$((${headend[$a]}-${headstart[$a]}+1))
	    #echo "Line: $c Start:${headstart[$a]} Count:$d" >> "$file.result"
	    substr="${dataline[$c]:${headstart[$a]}:$d}"; substr=$( trim "$substr" )
	    datastr="${datastr};${substr}"
	done
	datastr="${datastr:1:(${#datastr}-1)}"
	echo "$datastr" >> "$file"
    done
    
    unset headstr
    unset headstart
    unset headend
    unset headline
    unset dataline
    if [[ -f "$file.result" ]]; then rm "$file.result"; fi
    if [[ -f "$file.head" ]]; then rm "$file.head"; fi
    if [[ -f "$file.data" ]]; then rm "$file.data"; fi
}

        
# for NetApp
value64bit() {
    local power32=4294967296
    local value64high=$1
    local value64low=$2
    local value=0
    
    #v1
    value=$value64low
    if [[ "$value64low" -lt "0" ]]
    then 
    	value=$(((($value64high+1)*$power32)+$value))
    else 
    	value=$((($value64high*$power32)+$value))
    fi
    #v2
    #if [[ "$value64low" < "0" ]]
    #then 
    #	value=$(($power32+$value64low))
    #else 
    #	value=$(($value64low))
    #fi
    #value=$(($value+$value64high*$power32))

    echo -n "$value"
}


# for Stor2RRD
getpart() {
    local fout=$1
    local fname=$2
    local title=$3

    cat "$fname" | grep -A 1000 "$title" | tail -n +3 > "$fout"

    declare -a strings
    local index=0
    local str=""
    
    #Run down to next section, without empty strings
    while read str; do
        strings[$index]="$str"
        index=$(($index+1))
    done < "$fout"

    if [[ -f $fout ]]; then rm $fout; fi
    local a=0
    for ((a=0; a < $index; a++))
    do
	str=$( trim "${strings[$a]}" )
	if [[ "${str:0:9}" != "---------" ]]
	then
	    if [[ "$str" != "" ]]; then echo "${strings[$a]}" >> "$fout"; fi
	else
	    a+=1000
	fi
    done

    #Run down without last string
    local index=0
    while read str; do
        strings[$index]="$str"
        index=$(($index+1))
    done < "$fout"

    if [[ -f $fout ]]; then rm $fout; fi
    local a=0
    index=$(($index-1))
    for ((a=0; a < $index; a++))
    do 
	str=$( trim "${strings[$a]}" )
	echo "$str" >> "$fout"; 
    done

    unset strings
}

