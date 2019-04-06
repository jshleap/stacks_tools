#!/usr/bin/env bash
# 1 samples dir
# 2 popfile
# 3 ncpus
get_n(){
em=$1
ns="$(( em - 1 )) ${em} $(( em + 1 ))"
}

exe_bash(){
directory="m${1}_M${2}_n${3}"
samples_dir=$4
pop_subset=$5
ncpus=$6
mkdir -p ${directory}
c=0
parallel --will-cite --xapply ustacks -t gzfastq -f {2} -o ${directory} \
-i {1} -m $1 -p ${ncpus} -M $2 ::: `seq 10` :::: subset.samples
cstacks -P ${directory} -M ${pop_subset} -p ${ncpus} -n $3
sstacks -P ${directory} -M ${pop_subset} -p ${ncpus}
tsv2bam -P ${directory} -M ${pop_subset} -t ${ncpus}
gstacks -P ${directory} -M ${pop_subset} -t ${ncpus}
stacks-dist-extract ${directory}/gstacks.log.distribs effective_coverages_per_sample >  ${directory}/cov_r8.tsv
populations -P ${directory} -M ${pop_subset} -r 0.8 --vcf --hwe -t ${ncpus}
stacks-dist-extract ${directory}/populations.log.distribs snps_per_loc_postfilters > ${directory}/snps_r8.tsv
het=`zcat ${directory}/catalog.snps.tsv.gz| grep -v '#' | awk -F $'\t' ' $4 = "E" '| wc -l`
echo -e "${directory}\t${het}" >> counts_het.tsv
#denovo_map.pl --samples ${samples_dir} --popmap $5 -T 32 -o ${directory} -m ${1} -M ${2} -n ${3}
}

samples=$1
popmap=$2
ncpus=$3
# set parameter space
m=`seq 3 7`
M=`seq 1 8`
# get a subset of samples to test on
if [[ ! -f subset.samples ]]; then
    find ${samples}/ -name *.fq.gz |sort -R |tail -10 > subset.samples
fi
# subset the popfile
if [[ ! -f subset.popmap ]]; then
    while read line; do
        sample=`basename ${line}`
        grep "${sample%%.fq.gz}\s" ${popmap} >> subset.popmap
    done<subset.samples
fi
for lem in ${m};do
    for bem in ${M};do
        get_n ${bem}
        for n in ${ns}; do
        if [[ ! -f m${lem}_M${bem}_n${n}/catalog.snps.tsv.gz ]]; then
                exe_bash ${lem} ${bem} ${n} ${samples} subset.popmap ${ncpus}
        fi
        done
    done
done