../interm/benchmarkFeaturesTrain: ../interm/train ../interm/transact_train
	python feature.py --history=../interm/train --transactions=../interm/transact_train --out=../interm/_benchmarkFeaturesTrain
	mv ../interm/_benchmarkFeatureTrain ../interm/benchmarkFeatureTrain

../interm/benchmarkFeaturesTest: ../interm/test ../interm/transact_test
	python feature.py --history=../interm/test --transactions=../interm/transact_test --out=../interm/_benchmarkFeaturesTest
	mv ../interm/_benchmarkFeatureTest ../interm/benchmarkFeatureTest

all: ../target/resultBenchmarkTest
	python ../roc.py  --data=../interm/test --out=../target/resultBenchmarkTest

submission:
	echo "You're not serious..."
