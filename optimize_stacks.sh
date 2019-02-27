#!/usr/bin/env bash
# 1 samples dir
# 2 popfile
get_n(){
em=$1
ns="$(( em - 1 )) ${em} $(( em + 1 ))"
}

exe_bash(){
directory="m${1}_M${2}_n${3}"
mkdir -p ${directory}
denovo_map.pl --samples ${4} --popmap $5 -T 32 -o ${directory} -m ${1} -M ${2} -n ${3}
}

samples=$1
popmap=$2
# set parameter space
m=`seq 3 7`
M=`seq 1 8`
for lem in ${m};do
    for bem in ${M};do
        get_n ${bem}
        for n in ${ns}; do
        if [[ ! -f m${lem}_M${bem}_n${n}/catalog.snps.tsv ]]; then
                exe_bash ${lem} ${bem} ${n} ${samples} ${popmap}
        fi
        done
    done
done
