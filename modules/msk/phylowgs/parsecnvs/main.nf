process PHYLOWGS_PARSECNVS {
    tag "$meta.id"
    label 'process_low'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://ghcr.io/mskcc-omics-workflows/phylowgs:v1.5.2-msk':
        'ghcr.io/mskcc-omics-workflows/phylowgs:v1.5.2-msk' }"

    input:
    tuple val(meta), path(facetsgenelevel)

    output:
    tuple val(meta), path("cnvs.txt"), emit: cnv
    path "versions.yml"              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    // Call the module-bundled parse_cnvs.py by explicit path. The phylowgs image (>=1.5.2-msk) puts its own
    // /usr/bin/phylowgs/parser first on PATH, and moduleBinaries only appends to PATH, so the image's copy
    // (which crashes on FACETS segments with cf.em == NA) would otherwise shadow the patched bundled one.
    """
    python2 ${moduleDir}/resources/usr/bin/parse_cnvs.py \\
        ${args} \\
        ${facetsgenelevel}

    cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    phylowgs: \$PHYLOWGS_TAG
	END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch cnvs.txt

    cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    phylowgs: \$PHYLOWGS_TAG
	END_VERSIONS
    """
}
