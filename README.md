# SpikeN

SpikeN is a bioinformatic pipeline that allows the computational "spike-in" of sequence data into a separate sequence data set at a specified percentage of reads. 

SpikeN was initially developed to benchmark pathogen detection methods within metagenomic datasets. By spiking in an isolate into a metagenomic dataset, the percentage of isolate reads required to effectively detect the isolate amongst the metagenome could be determined.  

## Options 

```
  	-h [--help]		Display help message
	-i [--isolate]		Isolate to be spiked-in.
					              Must be in gzipped fastq format
	-m [--metagenome]	Metagenome that will be spiked with isolate. 
					              Must be in gzipped fastq format
	-o [--output]		Base file name for gzipped output
	-p [--percentage]	Percentage of isolate reads to be spiked in
	-s [--seed]		Random seed for shuffling metagenome following
	        				      spike-in
	-r [--report]
```

## Usage 

```
spikeN --isolate $ISOLATE_SEQ.fastq.gz --metagenome $METAGENOME_SEQ.fastq.gz --output $SPIKED_SEQ.fastq.gz --percentage 0.6 --seed 54
```

This will subsample 60% of the reads of contained in $ISOLATE_SEQ.fastq.gz. These reads will then be spiked in to $METAGENOME_SEQ.fastq.gz and shuffled using seqtk (seed: 54). The shuffled and spiked-in fastq file is then output as $SPIKED_SEQ.fastq.gz

## Output 

SpikeIn will produce a gzipped fastq file that contains the metagenome with spiked-in isolate reads. 

If a report directory is specified, the pipeline will produce a report file. An example report file is given below: 
```
### SpikeN Report

Isolate file spiked: /QNAP/kaleb/Reads/Nanopore/SS19M2901.clean.fastq.gz
Metagenome file spiked:  /QNAP/kaleb/IsoSpiked/MG2/spikeCTRL/MG2_CTRL_Spike.fq.gz
Total Reads spiked in:  263.700
Seed:  94

Read Ids: 
@1da5da00-6ad0-4107-9d57-e8593e08ccf9
@8039fb3f-1ffa-438b-8f70-0bd7b083b878
@ea45c2cf-ece5-4fc5-833a-f647bbad6ed2
@add32209-1b5e-4fa3-861f-34b7c2bb3162
@e85143b0-b066-41d5-a930-1190aae71eb9
@e40c3752-7e8c-47ff-a1dc-378a4bccb3b0
@718993f7-e4f9-420a-b235-6c821fbe3f12

```
Note: Not all read headers are listed in this example for space purposes. 
