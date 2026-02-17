include { validateParameters } from 'plugin/nf-schema'
validateParameters()


process fastq_filter {
    container 'fastq_rs:latest'

    publishDir "${params.outdir}/${id}/trim", mode: 'copy'

    input:
    tuple val(id), path(fastq)

    output:
    tuple val(id), path(outfile)

    script:
    outfile = "${id}.fastq.gz"
    """
    fastq_rs filter -f ${fastq} \
        --min-len ${params.filter.min_len} \
        --max-len ${params.filter.max_len} \
        --max-error ${params.filter.max_error} \
        -o ${outfile}
    """
}


workflow {
    if (!params.input_tsv) error "Please provide --input_tsv"

    ch_input = Channel
        .fromPath(params.input_tsv)
        .splitCsv(header: true, sep: "\t")
        .map { row -> [ row.id, file(row.fastq) ] }

    fastq_filter(ch_input)
}
