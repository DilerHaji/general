import re
import sys
import os
from Bio import SeqIO

multi_list = [ ]
single_list = [ ]

blastfilearg = sys.argv[1]
evalue = float(sys.argv[2])

blastfile = open(blastfilearg, "rU")

for result in blastfile:
    column = re.split(r"\t|\n",result)
    if ";" in column[12] and float(column[10]) < float(evalue):
        multi_list.append(column[12])
    elif float(column[10]) < float(evalue):
        single_list.append(column[12])

unique_taxids = list(set(single_list)) 
unique_multi_taxids = list(set(multi_list))

# Extracting 
                                                                                    
wanted = [line.strip() for line in unique_taxids]                               
seqiter = SeqIO.parse(open(sys.argv[3]), 'fasta')                                    
SeqIO.write((seq for seq in seqiter if seq.id in wanted), sys.stdout, "fasta")












