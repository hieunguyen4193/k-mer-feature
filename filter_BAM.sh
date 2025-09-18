inputbed="./panels/panel_20250918.bed";
bedname=$(echo $inputbed | xargs -n 1 basename);
bedname=${bedname%.bed*};
outputdir="/mnt/DATASM14/DATA_HIEUNGUYEN/outdir/k-mer-feature";
mkdir -p ${outputdir}/${bedname}/by_region;
mkdir -p ${outputdir}/${bedname}/full;

all_input_bams=$(cat full_metadata.csv | tail -n +2 | cut -d, -f4);

for inputbam in ${all_input_bams};do \
    filename=$(echo $inputbam | xargs -n 1 basename);
    echo -e "working on file "  $filename;

    ##### filter bam file with FULL BED FILE
    samtools view -b -h ${inputbam} -L ${inputbed} > ${outputdir}/${bedname}/full/${filename%.bam*}.filtered.bam;
    samtools index ${outputdir}/${bedname}/full/${filename%.bam*}.filtered.bam;

    ##### filter BAM file with each region in the bed file

    nregions=$(cat ${inputbed} | wc -l);
    for i in $(seq 1 $nregions); do \
        region=$(sed -n ${i}p ${inputbed} | awk '{print $1":"$2"-"$3}');
        regionname=$(sed -n ${i}p ${inputbed} | awk '{print $4}');
        echo -e "working on region " $regionname;
        echo -e "coordinate of regions: " $region;
        mkdir -p ${outputdir}/${bedname}/${regionname}
        samtools view -b -h ${inputbam} -L $region  > ${outputdir}/${bedname}/by_region/${regionname}/${filename%.bam*}.filtered.bam;
        samtools index ${outputdir}/${bedname}/by_region/${regionname}/${filename%.bam*}.filtered.bam;
    done;
done;