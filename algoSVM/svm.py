'''Run SVM using sklarn'''
import argparse
import csv
from sklearn import svm

def readAnnotatedFile(filename):
    trainfile = csv.reader(open(filename))
    trainfile.next() # header
    ids = []; X = []; y = []
    for line in trainfile:
        id = line[0]
        features = line[1:-1]
        output = 1 if line[-1] == 't' else 0
        ids.append(id)
        X.append(features)
        y.append(output)
    return (ids, X, y)

def writeProbFile(filename, ids, prob):
    file = open(filename, 'w')
    csvfile = csv.writer(file)
    csvfile.writerow(['id', 'repeatProbability'])
    for i, id in enumerate(ids):
        csvfile.writerow([id, prob[i]])
    file.close()

def run(train, test, outputTrain, outputTest):
    print("read in the training data")
    idTrain, X, y = readAnnotatedFile(train)

    print("initializing svm")
    clf = svm.SVC(probability=True)

    print("fitting svm")
    clf.fit(X, y)

    print("predicting svm value in training data")
    y_prob = [x[0] for x in clf.predict_proba(X)]
    writeProbFile(outputTrain, idTrain, y_prob)

    print("reading in test data")
    idTest, XNew, yNew = readAnnotatedFile(test)

    print("predicting svm value in test data")
    y_probTest = [x[0] for x in clf.predict_proba(X)]
    writeProbFile(outputTest, idTest, y_probTest)

    import pdb; pdb.set_trace()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Run SVM using sklearn')
    parser.add_argument('--train', dest='train', default='../interm/benchmarkFeaturesTrain')
    parser.add_argument('--test', dest='test', default='../interm/benchmarkFeaturesTest')
    parser.add_argument('--outTrain', dest='outTrain', default='../target/resultSVMTrainPY')
    parser.add_argument('--outTest', dest='outTest', default='../target/resultSVMTestPY')
    args = parser.parse_args()
    run(args.train, args.test, args.outTrain, args.outTest)
