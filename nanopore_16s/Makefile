.PHONY: build-containers run-test cleanup


build-containers:
	echo "-- building fastq_rs image..."
	@docker build -t fastq_rs:latest --file docker/Dockerfile.fastq_rs .

	echo "-- fetching and building amplipore image..."
	@git clone --branch nextflow https://github.com/OscarAspelin95/amplipore.git \
	&& cd amplipore && make build && cd .. && sudo rm -r amplipore


run-test:
	@nextflow run main.nf --input_tsv ./test_data/test.tsv --outdir "test_run" -profile "16s_nanopore_hac"


cleanup:
	sudo rm -rf .nextflow* test_run/ work/

docker-prune:
	@docker system prune --volumes -f
