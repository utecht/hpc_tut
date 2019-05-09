#!/bin/bash
regex='\/home\/([^\/]+)\/hpc_tut'
[[ $(pwd) =~ $regex ]]
echo "What email would you like to be notified?"
read email
echo "Changing your path to ${BASH_REMATCH[1]}"
for f in steps/*.script; do
  sed -i "s/<PATH>/${BASH_REMATCH[1]}/g" $f
  sed -i "s/<EMAIL>/$email/g" $f
done
echo "Downloading Sample Data"
wget -O data/sample-metadata.tsv https://data.qiime2.org/2019.4/tutorials/moving-pictures/sample_metadata.tsv
wget -O data/emp-single-end-sequences/sequences.fastq.gz https://data.qiime2.org/2019.4/tutorials/moving-pictures/emp-single-end-sequences/sequences.fastq.gz
wget -O data/emp-single-end-sequences/barcodes.fastq.gz https://data.qiime2.org/2019.4/tutorials/moving-pictures/emp-single-end-sequences/barcodes.fastq.gz
wget -O data/gg-13-8-99-515-806-nb-classifier.qza https://data.qiime2.org/2019.4/common/gg-13-8-99-515-806-nb-classifier.qza
