import argparse
import csv

from settings import TRANSACTIONS, OFFER
from random import random

class Algorithm:
    def __init__(self):
        return
    def train(self, transactions=TRANSACTIONS, offer=OFFER):
        return
    def test(self, event):
        return random()

def run(train, out):
    algo = Algorithm()

    trainfile = csv.DictReader(open(train))
    # arrays
    y_ids = []
    y_true = []
    y_scores = []
    for event in trainfile:
        id = event['id']
        y_ids.append(id)
        y_true.append(event['repeater'] == 't')
        prob = algo.test(event)
        y_scores.append(prob)
    if out is not None: # write to file
        outfile = csv.writer(open(out, 'w'))
        outfile.writerow(['id','repeatProbability'])
        for i, id in enumerate(y_ids):
            outfile.writerow([id, y_scores[i]])

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Test the result of an algo')
    parser.add_argument('--data', dest='data', default="data/trainHistory")
    parser.add_argument('--out', dest='out', default=None)
    args = parser.parse_args()

    run(args.data, args.out)
