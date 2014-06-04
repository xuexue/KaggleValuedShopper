import argparse
import csv
import numpy as np
from sklearn.metrics import roc_auc_score

def run(actual, model):
    actualfile = csv.reader(open(actual))
    modelfile = csv.reader(open(model))
    # headers
    actualfile.next()
    modelfile.next()
    # arrays
    y_true = []
    y_scores = []
    for line in actualfile:
        id = line[0]
        repeater = int(line[5] == 't')
        id2, probability = modelfile.next()
        probability = float(probability)
        if id != id2:
            raise ValueError("Out-of-order IDs %s != %s" % (id, id2))
        y_true.append(repeater)
        y_scores.append(probability)
    return roc_auc_score(np.array(y_true), np.array(y_scores))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Test the result of an algo')
    parser.add_argument('--actual', dest='actual', default="data/trainHistory")
    parser.add_argument('--model', dest='model')
    args = parser.parse_args()

    print "Running ROC score"
    score = run(args.actual, args.model)
    print "Got score: %3.f" % score
