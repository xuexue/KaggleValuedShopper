all: ../interm/benchmarkFeaturesTrain ../interm/benchmarkFeaturesTest
	echo "Run models.R instead"

../target/resultBenchmark: ../interm/benchmarkFeaturesTrain ../interm/benchmarkFeaturesTest ../interm/benchmarkFeaturesSubmit
	RScript submission.R ../interm/benchmarkFeaturesTrain ../interm/benchmarkFeaturesTest ../interm/benchmarkFeaturesSubmit ../target/resultBenchmark

submission: ../target/resultBenchmark
