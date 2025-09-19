export PATH=/Users/hieunguyen/samtools/bin:$PATH

inputdir="/Volumes/HNSD01/outdir/k-mer-feature/data_analysis/20250918/panel_20250918";
outputdir="/Volumes/HNSD01/outdir/k-mer-feature/data_analysis/20250918/panel_20250918_kmer_counts";
tmpdir="/Volumes/HNSD01/outdir/k-mer-feature/data_analysis/20250918/panel_20250918_kmer_counts/tmp"
mkdir -p $outputdir;
mkdir -p $tmpdir;
mkdir -p $outputdir/full;
mkdir -p $outputdir/by_region;

remove_tmp="true";

##### get KMC3
# download the KMC tool from https://github.com/refresh-bio/KMC/releases
kmc="/Users/hieunguyen/src/k-mer-feature/bin/kmc";
kmc_tools="/Users/hieunguyen/src/k-mer-feature/bin/kmc_tools";

kmer_size=4;

if [ "$kmer_size" -eq 2 ] || [ "$kmer_size" -eq 3 ]; then
    cs_option="-cs100000"
else
    cs_option=""
fi

##### generate k-mers for full bam
all_full_bams=$(ls ${inputdir}/full/*.bam);

for inputbam in ${all_full_bams};do \
    sampleid=$(echo ${inputbam} | xargs -n 1 basename);
    sampleid=${sampleid%.bam*};
    echo -e "working on " ${sampleid};

    # convert bam to fastq 
    samtools bam2fq ${inputbam} > ${tmpdir}/${sampleid}.fastq;

    # count k-mers with kmc3
    ${kmc} -k${kmer_size} ${cs_option} ${tmpdir}/${sampleid}.fastq ${sampleid}_${kmer_size} . ; 

    # dump k-mer counts from k-mer database output
    mv ${sampleid}_${kmer_size}*.kmc* ${outputdir}/full;

    ${kmc_tools} transform \
        ${outputdir}/full/${sampleid}_${kmer_size} dump \
        ${outputdir}/full/${sampleid}_${kmer_size}.txt;
    done

if [ "${remove_tmp}" = "true" ]; then
    rm -rf "${tmpdir}"
fi

##### generate k-mers by region
all_regions=$(ls ${inputdir}/by_region -d);
for region in ${all_regions};do \
    regionname=$(echo $region | xargs -n 1 basename);
    echo -e "working on region " ${regionname};
    mkdir -p ${tmpdir}/${regionname};
    mkdir -p ${outputdir}/by_region/${regionname};

    all_bam_files_in_regions=$(ls ${inputdir}/by_region/${regionname}/*.bam);
    for inputbam in ${all_bam_files_in_regions};do \
        sampleid=$(echo ${inputbam} | xargs -n 1 basename);
        sampleid=${sampleid%.bam*};
        echo -e "working on sample " ${sampleid};
        samtools bam2fq ${inputbam} > ${tmpdir}/${regionname}/${sampleid}.fastq;

        # count k-mers with kmc3
        ${kmc} -k${kmer_size} ${cs_option} ${tmpdir}/${regionname}/${sampleid}.fastq ${sampleid}_${kmer_size} . ;

        # dump k-mer counts from k-mer database output
        mv ${sampleid}_${kmer_size}*.kmc* ${outputdir}/by_region/${regionname};

        ${kmc_tools} transform \
            ${outputdir}/by_region/${regionname}/${sampleid}_${kmer_size} dump \
            ${outputdir}/by_region/${regionname}/${sampleid}_${kmer_size}.txt;
    done
    if [ "${remove_tmp}" = "true" ]; then
        rm -rf "${tmpdir}"
    fi
done