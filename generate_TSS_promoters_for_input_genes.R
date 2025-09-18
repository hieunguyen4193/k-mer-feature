gc()
rm(list = ls())

path.to.main.src <- "/home/hieunguyen/src/k-mer-feature"
source(file.path(path.to.main.src, "define_promoter_regions_TSS.R"))
library(comprehenr)
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

source(file.path(path.to.main.src, "gene_lists.R"))
if ("biomaRt" %in% installed.packages() == FALSE){
  install.packages("dplyr")
  BiocManager::install("biomaRt", update = FALSE)  
}

library(comprehenr)
library(biomaRt)
library(tidyverse)
library(dplyr)

##### note
# downgrade dbplyr if you get the error
# Error in `collect()`: ! Failed to collect lazy table. Caused by error in `db_collect()`: 
# ! Arguments in `...` must be used. 
# Problematic argument: • ..1 = Inf 
# Did you misspell an argument name? Run `rlang::last_trace()` to see where the error occurred.
# install.packages('https://cran.r-project.org/src/contrib/Archive/dbplyr/dbplyr_2.3.4.tar.gz', repos = NULL)

ensembl <- useEnsembl(biomart = "genes", dataset = "hsapiens_gene_ensembl", mirror = "www")
tss_data <- getBM(
  attributes = c("chromosome_name", "transcription_start_site", 
                 "strand", "external_gene_name", "ensembl_gene_id"),
  mart = ensembl
)

bed <- tss_data
bed$chromosome_name <- paste0("chr", bed$chromosome_name)
bed$start <- bed$transcription_start_site - 1  # BED is 0-based
bed$end <- bed$transcription_start_site

bed_formatted <- bed[, c("chromosome_name", "start", "end", "external_gene_name", "ensembl_gene_id", "strand")]
colnames(bed_formatted) <- c("chr", "start", "end", "name", "gene_id", "strand")

# tssdf <- read.csv(path.to.TSS.file, sep = "\t", header = FALSE)[c("V2", "V3", "V4", "V7", "V12")]
tssdf <- bed_formatted[, c("chr", "start", "end", "strand", "name")]
colnames(tssdf) <- c("chrom", "start", "end", "strand", "gene")
tssdf$strand <- to_vec(
  for (item in tssdf$strand){
    if (item == 1){
      return("+")
    } else {
      return("-")
    }
  }
)

tssdf <- tssdf %>% rowwise() %>%
  mutate(tssName = sprintf("%s_%s_%s", chrom, start, end))

#####

# cancer.type <- "Lung"
# gene.list.version <- "v0.1"

for (cancer.type in names(gene.list)){
  for (gene.list.version in names(gene.list[[cancer.type]])){
    path.to.save.output <- file.path(path.to.main.src, "custom_tss_gene_beds", cancer.type, gene.list.version)
    dir.create(path.to.save.output, showWarnings = FALSE, recursive = TRUE)
    
    full.genes <- c(gene.list[[cancer.type]][[gene.list.version]]$up, 
                    gene.list[[cancer.type]][[gene.list.version]]$down)
    up.genes <- gene.list[[cancer.type]][[gene.list.version]]$up
    down.genes <- gene.list[[cancer.type]][[gene.list.version]]$down
    
    tssdf.up <- subset(tssdf, tssdf$gene %in% up.genes)
    tssdf.down <- subset(tssdf, tssdf$gene %in% down.genes)
    tssdf.full <- subset(tssdf, tssdf$gene %in% full.genes)
    
    promoterdf <- define_promoter_regions(tssdf = tssdf.up, 
                                          up.flank = 1000, 
                                          down.flank = 1000, 
                                          outputdir = file.path(path.to.save.output, "biomart", "up_genes"))
    
    promoterdf <- define_promoter_regions(tssdf = tssdf.down, 
                                          up.flank = 1000, 
                                          down.flank = 1000, 
                                          outputdir = file.path(path.to.save.output, "biomart", "down_genes"))
    
    promoterdf <- define_promoter_regions(tssdf = tssdf.full, 
                                          up.flank = 1000, 
                                          down.flank = 1000, 
                                          outputdir = file.path(path.to.save.output, "biomart", "all_genes"))
    
    
  }
}
#####