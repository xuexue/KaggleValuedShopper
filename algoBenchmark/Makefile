../interm/benchmarkFeaturesTrain: ../interm/train ../interm/transact_train
	python feature.py --history=../interm/train --transactions=../interm/transact_train --out=../interm/_benchmarkFeaturesTrain
	mv ../interm/_benchmarkFeatureTrain ../interm/benchmarkFeatureTrain

../interm/benchmarkFeaturesTest: ../interm/test ../interm/transact_test
	python feature.py --history=../interm/test --transactions=../interm/transact_test --out=../interm/_benchmarkFeaturesTest
	mv ../interm/_benchmarkFeaturesTest ../interm/benchmarkFeaturesTest

all: ../interm/benchmarkFeaturesTrain ../interm/benchmarkFeaturesTest
	echo "Run models.R instead"

../interm/benchmarkFeaturesSubmit: ../data/testHistory
	pypy feature.py --history=../data/testHistory --transactions=../interm/transact_submit --out=../interm/_benchmarkFeaturesSubmit
	mv ../interm/_benchmarkFeaturesSubmit ../interm/benchmarkFeaturesSubmit

../target/resultBenchmark: ../interm/benchmarkFeaturesTrain ../interm/benchmarkFeaturesTest ../interm/benchmarkFeaturesSubmit
	RScript submission.R ../interm/benchmarkFeaturesTrain ../interm/benchmarkFeaturesTest ../interm/benchmarkFeaturesSubmit ../target/resultBenchmark

submission: ../target/resultBenchmark
