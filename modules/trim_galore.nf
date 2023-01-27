#!/usr/bin/env nextflow

/*
Coriell Institute for Medical Research
Bisulfite Amplicon Pipeline. Started January 2023.

Contributors:
Anthony Pompetti <apompetti@coriell.org>
*/

/*
Enable Nextflow DSL2
*/
nextflow.enable.dsl=2

/*
Define local params 
*/
params.outdir = "./results"
params.pubdir = "trim_galore"
params.singleEnd = false
params.min_length = 20

/*
Run trim_galore on each read stored within the reads_ch channel
*/
process trim_galore {
    maxForks 3
    memory '8 GB'
    cpus 4

    publishDir "${params.outdir}/${params.pubdir}", mode: 'copy'

    input:
    tuple val(file_id), path(reads)

    output:
    tuple val(file_id), path("*.fq.gz"), emit: trimmed_reads
    path("*trimming_report.txt"), emit: trimming_report

    script:
    if ( params.singleEnd )
    """
    trim_galore \
    --length ${params.min_length} \
    --cores ${task.cpus} \
    $reads
    """

    else
    """
    trim_galore \
    --length ${params.min_length} \
    --paired \
    --cores ${task.cpus} \
    $reads
    """
}