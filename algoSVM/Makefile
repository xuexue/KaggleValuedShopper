../target/resultSVMR ../target/resultSVMTrain: ../interm/benchmarkFeaturesTrain ../interm/benchmarkFeaturesTest ../interm/benchmarkFeaturesSubmit
	RScript svm.R ../interm/benchmarkFeaturesTrain ../interm/benchmarkFeaturesTest ../interm/benchmarkFeaturesSubmit ../target/resultSVMTrain ../target/resultSVMR

submission: ../target/resultSVMR ../target/resultSVMTrain
