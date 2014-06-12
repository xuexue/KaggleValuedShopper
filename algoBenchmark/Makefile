../interm/benchmarkFeaturesTrain: ../interm/train ../interm/transact_train
	python feature.py --history=../interm/train --transactions=../interm/transact_train --out=../interm/_benchmarkFeaturesTrain
	mv ../interm/_benchmarkFeatureTrain ../interm/benchmarkFeatureTrain


all: ../target/resultBenchmarkTest
	python ../roc.py  --data=../interm/test --out=../target/resultBenchmarkTest

submission:
	echo "You're not serious..."
