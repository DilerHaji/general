#!/bin/bash
#SBATCH --job-name=deroRNAtree
#SBATCH --partition=general
#SBATCH --mail-type=END
#SBATCH --mail-user=diler.haji@uconn.edu
#SBATCH --mem=120G

module load RAxML/8.2.11

array=(mbset95 mbset90 mbset80 mbset50)

for a in "${array[@]}";
do
cd /home/CAM/dhaji/Derotettix_28S/raxml
mkdir ${a}
cd ${a}
raxmlHPC -p 1234 -f a -s ../${a}.fasta -m GTRGAMMA -# 100 -x 12345 -n ${a}
done

