import re
import sys

multi_list = [ ]
single_list = [ ]

blastfilearg = sys.argv[1]
evalue = float(sys.argv[2])

blastfile = open(blastfilearg, "rU")

for result in blastfile:
    column = re.split(r"\t|\n",result) #this splits the file on the tab character to make columns and also splits off the end of line character \n into its own column
    if ";" in column[12] and float(column[10]) < float(evalue):#if multiple ids and length of alignemtn is greater than 50bp and the evalue is less than 0.0001 then ...
        multi_list.append(column[1])
    elif float(column[10]) < float(evalue):#if not multiple ids and length of alignemtn is greater than 50bp and the evalue is less than 0.0001 then ...
        single_list.append(column[1])

unique_taxids = list(set(single_list)) #changing to a set just selects unique values
unique_multi_taxids = list(set(multi_list)) #changing to a set just selects unique values

outfile = open("unique_taxids" , "w")
for line in unique_taxids:
  outfile.write(line)
  outfile.write("\n")
outfile.close()

outfile = open("unique_multi_taxids" , "w")
for line in unique_multi_taxids:
  outfile.write(line)
  outfile.write("\n")
outfile.close()


