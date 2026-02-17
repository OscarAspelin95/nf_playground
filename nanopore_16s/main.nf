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

process classification {
    container 'amplipore:latest'

    publishDir "${params.outdir}/${id}/classification", mode: 'copy'

    input:
    tuple val(id), path(fastq)

    output:
    tuple val(id), path(outdir)

    script:
    outdir = "."
    """
        uv run /usr/src/app/main.py \
            -f ${fastq} \
            --kmer-size ${params.classification.kmer_size} \
            --sintax-threshold ${params.classification.sintax_threshold} \
            --cluster-pident ${params.classification.cluster_pident} \
            --window-size ${params.classification.window_size} \
            -o ${outdir}
    """
}


workflow {
    if (!params.input_tsv) error "Please provide --input_tsv"

    ch_input = Channel
        .fromPath(params.input_tsv)
        .splitCsv(header: true, sep: "\t")
        .map { row -> [ row.id, file(row.fastq) ] }

    // fastq_rs filter
    ch_filtered_fastq = fastq_filter(ch_input)

    // amplipore classification
    out = classification(ch_filtered_fastq)
}
