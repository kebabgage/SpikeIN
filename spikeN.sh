#!/bin/bash
usage() {
	echo "Usage $0 [-i] [-m] [-o] [-s] [-p] [-s]" 
	echo
	echo "Spike in isolate into metagenome at specified percentage of isolate"
	echo
	echo "Options:" 
	echo "	-h [--help]		Display help message"
	echo "	-i [--isolate]		Isolate to be spiked-in." 
	echo "					Must be in gzipped fastq format"
	echo "	-m [--metagenome]	Metagenome that will be spiked with isolate." 
	echo "					Must be in gzipped fastq format"
	echo "	-o [--output]		Base file name for gzipped output"
	echo "	-p [--percentage]	Percentage of isolate reads to be spiked in"
	echo "	-s [--seed]		Random seed for shuffling metagenome following"
	echo "					spike-in"
					
}
while [ "$1" != "" ]; do
	case $1 in
		-i | --isolate)		shift
					isolate=$1
					;;
		-m | --metagenome)	shift
					metagenome=$1
					;;
		-p | --percentage)	shift
					percentage=$1
					;;
		-o | --output)		shift
					output=$1
					;;
		-s | --seed) 		shift
					declare -i sampleSeed=$1
					;;
		-h | --help)		usage
					exit
					;;
		-t | --temp)		shift 
					TEMP_DIR=$1
					;;
		-*)			echo "Error: Unkown options: $1"
					usage
					exit 1
					;;
		* )
					exit
	esac 
	shift
done
source activate nanopore

mkdir ${TEMP_DIR}

# Count the amount of reads in the isolate 
isolateCount=$(echo "$(zcat $isolate| wc -l)/4" | bc)
echo "Isolate has" $isolateCount "reads"

isolateFraction=$(echo "$isolateCount * $percentage" | bc)
echo "Subsampling" $(echo "$percentage * 100"| bc) "percent of isolate reads:" $isolateFraction "reads in total" 
conda deactivate

source activate beatson_py3
seqtk sample -s $sampleSeed $isolate $isolateFraction | gzip > ${TEMP_DIR}/subSampleIsolate.fq.gz 
conda deactivate

source activate nanopore

# Append isolate subsample to metagenome
zcat $metagenome ${TEMP_DIR}/subSampleIsolate.fq.gz | gzip > ${TEMP_DIR}/metaAppendIsolate.fq.gz

# Shuffle metagenome | gzip 
seqkit shuffle ${TEMP_DIR}/metaAppendIsolate.fq.gz | gzip > $output.gz
conda deactivate 
#rm subSampleIsolate.fq.gz
rm ${TEMP_DIR}/metaAppendIsolate.fq.gz
echo "Spike-in complete"
