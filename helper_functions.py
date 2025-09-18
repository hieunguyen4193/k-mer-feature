import pandas as pd 
import pyfaidx
import pysam
import os 

#####
def get_refseq(fapath, chrom, start, end, additional_flanking_size = 0):
    """
    Retrieves the reference sequence from a given FASTA file.
    Args:
        path_to_all_fa (str): The path to the directory containing all the FASTA files.
        chrom (str): The chromosome identifier.
        start (int): The starting position of the sequence.
        end (int): The ending position of the sequence.
    Returns:
        str: The uppercase reference sequence.
    Raises:
        FileNotFoundError: If the FASTA file for the specified chromosome is not found.
    """
    refseq = pyfaidx.Fasta(fapath)
    return(str.upper(refseq.get_seq(name = chrom, 
                                    start = start - additional_flanking_size, 
                                    end = end + additional_flanking_size).seq))

#####
def kmer_occurence_count(seq, k):
    output = {}
    size = len(seq)
    for i in range(size - k + 1):
        kmer = seq[i: i + k]
        try:
            output[kmer] += 1
        except KeyError:
            output[kmer] = 1
    return output