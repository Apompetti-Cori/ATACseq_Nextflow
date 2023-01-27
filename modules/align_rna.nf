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
params.pubdir = "align_rna"
params.singleEnd = false
params.db = false
params.threads = 8

process align_rna {
    maxForks 3
    memory '8 GB'
    cpus 1

    publishDir "${params.outdir}/${params.pubdir}", mode: 'copy'

    input:
    tuple val(file_id), path(reads)

    output:

    script:
    """
    salmon quant \
        -i ${params.db} \
        -l A \
        -1 ${reads[0]} \
        -2 ${reads[1]} \
        --validateMappings \
        --gcBias \
        --seqBias \
        --threads ${params.threads} \
        --output ${file_id}_quants;
    """
}