import argparse
import csv
import numpy as np

from sklearn.metrics import roc_auc_score

def get_roc_score(true, scores):
    return roc_auc_score(np.array(true), np.array(scores))

def compare(actual, model):
    actualfile = csv.DictReader(open(actual))
    modelfile = csv.DictReader(open(model))
    # arrays
    y_true = []
    y_scores = []
    for event in actualfile:
        id = event['id']
        repeater = event['repeater'] == 't'

        model_evt = modelfile.next()
        id2 = model_evt['id']
        probability = float(model_evt['repeatProbability'])

        if id != id2:
            raise ValueError("Out-of-order IDs %s != %s" % (id, id2))
        y_true.append(repeater)
        y_scores.append(probability)
    return get_roc_score(y_true, y_scores)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Test the result of an algo')
    parser.add_argument('--data', dest='data', default="data/trainHistory")
    parser.add_argument('--out', dest='out', default=None)
    args = parser.parse_args()

    print "Running ROC score"
    score = compare(args.data, args.out)
    print "Got score: %.3f" % score
