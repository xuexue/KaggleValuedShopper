../interm/benchmarkFeaturesTrain: ../interm/train ../interm/transact_train
	pypy feature.py --history=../interm/train --transactions=../interm/transact_train --out=../interm/_benchmarkFeaturesTrain
	mv ../interm/_benchmarkFeatureTrain ../interm/benchmarkFeatureTrain

../interm/benchmarkFeaturesSubmit: ../data/testHistory ../interm/transact_submit
	pypy feature.py --history=../data/testHistory --transactions=../interm/transact_submit --out=../interm/_benchmarkFeaturesSubmit

all: ../target/resultBenchmarkTest
	python ../roc.py  --data=../interm/test --out=../target/resultBenchmarkTest

submission:
	echo "You're not serious..."
