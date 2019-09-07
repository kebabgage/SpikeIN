# SpikeN

SpikeN is a bioinformatic pipeline that allows the computational "spike-in" of sequence data into a separate sequence data set at a specified percentage of reads. 

SpikeN was initially developed to benchmark pathogen detection methods within metagenomic datasets. By spiking in an isolate into a metagenomic dataset, the percentage of isolate reads required to effectively detect the isolate amongst the metagenome could be determined.  

## Options 

```
  	-h [--help]		Display help message"
	-i [--isolate]		Isolate to be spiked-in." 
					              Must be in gzipped fastq format"
	-m [--metagenome]	Metagenome that will be spiked with isolate." 
					              Must be in gzipped fastq format"
	-o [--output]		Base file name for gzipped output"
	-p [--percentage]	Percentage of isolate reads to be spiked in"
	-s [--seed]		Random seed for shuffling metagenome following"
	        				      spike-in"
```

## Usage 

```
spikeN --isolate $ISOLATE_SEQ.fastq.gz --metagenome $METAGENOME_SEQ.fastq.gz --output $SPIKED_SEQ.fastq.gz --percentage 0.6 --seed 54
```

This will subsample 60% of the reads of contained in $ISOLATE_SEQ.fastq.gz. These reads will then be spiked in to $METAGENOME_SEQ.fastq.gz and shuffled using seqtk (seed: 54). The shuffled and spiked-in fastq file is then output as $SPIKED_SEQ.fastq.gz
