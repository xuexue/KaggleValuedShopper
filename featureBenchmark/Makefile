../interm/benchmarkFeaturesTrain: ../interm/train ../interm/transact_train
	python feature.py --history=../interm/train --transactions=../interm/transact_train --out=../interm/_benchmarkFeaturesTrain
	mv ../interm/_benchmarkFeatureTrain ../interm/benchmarkFeatureTrain

../interm/benchmarkFeaturesTest: ../interm/test ../interm/transact_test
	python feature.py --history=../interm/test --transactions=../interm/transact_test --out=../interm/_benchmarkFeaturesTest
	mv ../interm/_benchmarkFeaturesTest ../interm/benchmarkFeaturesTest

../interm/benchmarkFeaturesSubmit: ../data/testHistory ../interm/transact_submit
	pypy feature.py --history=../data/testHistory --transactions=../interm/transact_submit --out=../interm/_benchmarkFeaturesSubmit
	mv ../interm/_benchmarkFeaturesSubmit ../interm/benchmarkFeaturesSubmit
