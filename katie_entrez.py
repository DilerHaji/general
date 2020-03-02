with open(sys.argv[1], "r") as result:
    result_handle = result.readlines()

import re

multi_list = [ ]
single_list = [ ]

for result in result_handle:
    column = re.split(r"\t|\n",result) 
    if ";" in column[12] and int(column[3]) > int(50) and float(column[10]) < float(0.0001):
        multi_list.append(column[12])
    elif int(column[3]) > int(50) and float(column[10]) < float(0.0001):
        single_list.append(column[12])

unique_taxids = list(set(single_list)) 
unique_multi_taxids = list(set(multi_list))

outfile = open("tid" , "w")
for line in unique_taxids:
  outfile.write(line)
  outfile.write("\n")
outfile.close()

outfile = open("tid2" , "w")
for line in unique_multi_taxids:
  outfile.write(line)
  outfile.write("\n")
outfile.close()

with open("/Users/Katie/desktop/Blast_Results_Parser/total_taxids2.txt", "r") as r:
    all_taxids = r.readlines()
unique_taxids= list(set(all_taxids))
bacteria_list = [ ]
fungal_list = [ ]
arthropod_list = [ ]
viral_list = [ ]
other_list = [ ]

#######
######
#######

from Bio import Entrez
Entrez.email = 'katherine.l.taylor@uconn.edu'

for line in unique_taxids:
    handle = Entrez.efetch(db="Taxonomy", id=line, retmode="xml")
    record = Entrez.read(handle)
    if "Arthropoda" in record[0]["Lineage"]:
        arthropod_list.append(line)
    elif "Bacteria" in record[0]["Lineage"]:
        bacteria_list.append(line)
    elif "Fungi" in record[0]["Lineage"]:
        fungal_list.append(line)
    elif "Viruses" in record[0]["Lineage"]:
        viral_list.append(line)
    else: 
        other_list.append(line)

outfile = open ("/Users/Katie/desktop/Blast_Results_Parser/all_bacterial_taxids2.txt" , "w")
for line in bacteria_list:
  outfile.write(line)
outfile.close()

outfile = open ("/Users/Katie/desktop/Blast_Results_Parser/all_other_taxids2.txt" , "w")
for line1 in other_list:
  outfile.write(line1)
outfile.close()

outfile = open ("/Users/Katie/desktop/Blast_Results_Parser/all_fungal_taxids2.txt" , "w")
for line2 in fungal_list:
  outfile.write(line2)
outfile.close()

outfile = open ("/Users/Katie/desktop/Blast_Results_Parser/all_arthropod_taxids2.txt" , "w")
for line3 in arthropod_list:
  outfile.write(line3)
outfile.close()

outfile = open ("/Users/Katie/desktop/Blast_Results_Parser/all_viral_taxids2.txt" , "w")
for line4 in viral_list:
  outfile.write(line4)
outfile.close()
#######
######
#####

with open("/Users/Katie/desktop/Blast_Results_Parser/masurca_bacterial_taxids.txt", "r") as bacterial_list:
    bacterial_list_handle = bacterial_list.readlines()
    
with open("/Users/Katie/desktop/Blast_Results_Parser/idba_blast_out_local_fmt6_top10.txt", "r") as result:
    result_handle = result.readlines()

bacterial_scaffold_list = [ ]    

for line in bacterial_list_handle:
    line_column = line.split("\n")
    for result in result_handle:
        result_column = re.split(r"\t|\n",result)
        if line_column[0] == result_column[12]:
            bacterial_scaffold_list.append(result_column[0])
 
 unique_bacterial_scaffolds = list(set(bacterial_scaffold_list))
 
outfile = open ("/Users/Katie/desktop/Blast_Results_Parser/masurca_bacterial_scaffolds.txt" , "w")
for line in unique_bacterial_scaffolds:
  outfile.write(line)
  outfile.write("\n")
outfile.close()
