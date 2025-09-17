# download the KMC tool from https://github.com/refresh-bio/KMC/releases
kmc="/Users/hieunguyen/src/k-mer-feature/bin/kmc";
kmc_tools="/Users/hieunguyen/src/k-mer-feature/bin/kmc_tools";

main_inputdir="/Volumes/HNSD01/outdir/highdepth_WGS_TSS_customGenes/fastq_single_file";
main_outputdir="/Volumes/HNSD01/outdir/highdepth_WGS_TSS_customGenes/kmc3_output";
kmc_dump_output="/Volumes/HNSD01/outdir/highdepth_WGS_TSS_customGenes/kmc3_dump_count";

# kmer_size=2;
kmer_size=3;
# kmer_size=24;

cancer_type="Lung"
tss_type="biomart";

if [ "$kmer_size" -eq 2 ] || [ "$kmer_size" -eq 3 ]; then
    cs_option="-cs100000"
else
    cs_option=""
fi

for enrichment in all_genes up_genes down_genes;do \
    inputdir=${main_inputdir}/$cancer_type/$tss_type/$enrichment;
    outputdir=${main_outputdir}/${cancer_type}/${tss_type}/${enrichment};
    mkdir -p ${outputdir};    
    all_fastqs=$(ls ${inputdir}/*.fastq);
    for input_fastq in ${all_fastqs}; do \
        sampleid=$(echo ${input_fastq} | xargs -n 1 basename);
        sampleid=${sampleid%.fastq*};
        echo -e "working on " ${sampleid};
        ${kmc} -k${kmer_size} ${cs_option} ${input_fastq} ${sampleid}_${kmer_size} . ; 
        mv ${sampleid}_${kmer_size}*.kmc* ${outputdir};

        explicit_outputdir=${kmc_dump_output}/${cancer_type}/${tss_type}/${enrichment};
        mkdir -p ${explicit_outputdir};

        ${kmc_tools} transform \
            ${outputdir}/${sampleid}_${kmer_size} dump \
            ${explicit_outputdir}/${sampleid}_${kmer_size}.txt
        done;done

