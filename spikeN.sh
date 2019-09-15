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
	echo "	-s [--seed]		Seed for shuffling metagenome following spike-in"
	echo "					[Randomly generated if not specified ]"
					
}

# If seed is entered as an option, this will be overwritten with specified seed 
sampleSeed=$((1 + RANDOM % 100))
REPORT_OUTPUT=""
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
		-r | --report)		shift
					REPORT_OUTPUT=$1
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

mkdir -p ${TEMP_DIR}

# Count the amount of reads in the isolate 
isolateCount=$(echo "$(zcat $isolate| wc -l)/4" | bc)
echo "Isolate has" $isolateCount "reads"

isolateFraction=$(echo "$isolateCount * $percentage" | bc)
echo "Subsampling" $(echo "$percentage * 100"| bc) "percent of isolate reads:" $isolateFraction "reads in total" 
conda deactivate

source activate beatson_py3
seqtk sample -s $sampleSeed $isolate $isolateFraction | gzip > ${TEMP_DIR}/subSampleIsolate.fq.gz 
conda deactivate
if [ "$REPORT_OUTPUT" != "" ]; then

	echo "### SpikeN Report" >> ${TEMP_DIR}/${REPORT_OUTPUT}
	echo "" >> ${TEMP_DIR}/${REPORT_OUTPUT} >> ${TEMP_DIR}/${REPORT_OUTPUT} 
	echo "Isolate file spiked:" $isolate >> ${TEMP_DIR}/${REPORT_OUTPUT}   
	echo "Metagenome file spiked: " $metagenome >> ${TEMP_DIR}/${REPORT_OUTPUT}   
	echo "Total Reads spiked in: " $isolateFraction >> ${TEMP_DIR}/${REPORT_OUTPUT} 
	echo "Seed: " $sampleSeed >> ${TEMP_DIR}/${REPORT_OUTPUT} 
	echo "" >> ${TEMP_DIR}/${REPORT_OUTPUT} 
	echo "Read Ids: " >> ${TEMP_DIR}/${REPORT_OUTPUT} 
	zcat ${TEMP_DIR}/subSampleIsolate.fq.gz | head -n 1 - | cut -d " " -f1 >> ${TEMP_DIR}/${REPORT_OUTPUT}
	zcat ${TEMP_DIR}/subSampleIsolate.fq.gz | sed '1d' - | awk  'NR % 4 == 0' - | cut -d " " -f1 >> ${TEMP_DIR}/${REPORT_OUTPUT} 

fi
source activate nanopore

# Append isolate subsample to metagenome
zcat $metagenome ${TEMP_DIR}/subSampleIsolate.fq.gz | gzip > ${TEMP_DIR}/metaAppendIsolate.fq.gz

# Shuffle metagenome | gzip 
seqkit shuffle ${TEMP_DIR}/metaAppendIsolate.fq.gz | gzip > ${TEMP_DIR}/${output}.fq.gz
conda deactivate 
rm ${TEMP_DIR}/subSampleIsolate.fq.gz
rm ${TEMP_DIR}/metaAppendIsolate.fq.gz
echo "Spike-in complete"
