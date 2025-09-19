export PATH=/Users/hieunguyen/samtools/bin:$PATH

main_inputdir="/Volumes/HNSD01/raw_data/highdepth_WGS_TSS_customGenes"
main_outputdir="/Volumes/HNSD01/outdir/highdepth_WGS_TSS_customGenes/fastq_single_file";
mkdir -p ${main_outputdir};

cancer_type="Lung"
tss_type="biomart";

for enrichment in all_genes up_genes down_genes;do \
    inputdir=${main_inputdir}/${cancer_type}/${tss_type}/${enrichment}
    outputdir=${main_outputdir}/${cancer_type}/${tss_type}/${enrichment};
    mkdir -p ${outputdir};
    all_bams=$(ls ${inputdir}/*.bam);
    for inputbam in ${all_bams}; do \
        sampleid=$(echo ${inputbam} | xargs -n 1 basename);
        sampleid=${sampleid%.bam*};
        echo -e "working on " ${sampleid};
        samtools bam2fq ${inputbam} > ${outputdir}/${sampleid}.fastq;
        done;done