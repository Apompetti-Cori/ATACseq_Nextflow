#!/usr/bin/env nextflow

/*
Coriell Institute for Medical Research
Bisulfite Amplicon Pipeline. Started January 2023.

Contributors:
Anthony Pompetti <apompetti@coriell.org>

Methodology adapted from:
prior ATAC seq workflow developed by Gennaro
*/

/*
Enable Nextflow DSL2
*/
nextflow.enable.dsl=2

//Configurable variables for pipeline
params.fastq_folder = "${workflow.projectDir}/fastq"
params.reads = "${params.fastq_folder}/*{_R,_}{1,2}*.{fastq,fq}.gz"
params.singleEnd = false
params.multiqc_config = "${workflow.projectDir}/multiqc_config.yaml"
params.genome = false
params.db = params.genomes ? params.genomes[ params.genome ].db ?:false : false

//Include modules to main pipeline
include { fastqc as pretrim_fastqc } from './modules/fastqc.nf' addParams(pubdir: '01_pretrim_fastqc')
include { trim_galore } from './modules/trim_galore.nf' addParams(pubdir: '02_trim')
include { fastqc as posttrim_fastqc } from './modules/fastqc.nf' addParams(pubdir: '03_posttrim_fastqc')
include { align_rna } from './modules/align_rna.nf' addParams(pubdir: '02b_align_rna')
include { multiqc} from './modules/multiqc.nf'

//Create channel for reads. By default, auto-detects paired end data. Specify --singleEnd if your fastq files are in single-end format
Channel
.fromFilePairs(params.reads, size: params.singleEnd ? 1 : 2)
.ifEmpty {exit 1, "Cannot find any reads matching ${params.reads}\nNB: Path needs to be enclosed in quotes!\nIf this is single-end data, please specify --singleEnd on the command line."}
.set{ reads_ch }

workflow {

    //Run fastqc on raw reads
    pretrim_fastqc(reads_ch)

    //Run trim_galore on raw reads
    trim_galore(reads_ch)

    //Run fastqc on trimmed reads, specifies trim_galore[0] because second input channel is not needed for this process
    posttrim_fastqc(trim_galore.out.trimmed_reads)

    //Compile fastqc reports 
    multiqc("${params.multiqc_config}", pretrim_fastqc.out.collect().combine(posttrim_fastqc.out.collect()).combine(trim_galore.out.trimming_report.collect()))

    //Align RNA-seq reads to GRCm39 transcriptome
    //align_rna(trim_galore.out.trimmed_reads)
}