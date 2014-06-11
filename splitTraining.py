'''Split the available training data into a TRAINING and TEST set'''
import argparse
import csv
import random

def run(history, train, test, testRate=0.2):
    historyfile = open(history)
    trainfile = open(train, 'w')
    testfile = open(test, 'w')

    header = historyfile.next() # header
    trainfile.write(header)
    testfile.write(header)

    for line in historyfile:
        if random.random() < testRate:
            testfile.write(line)
        else:
            trainfile.write(line)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Extract only useful transactions')
    parser.add_argument('--history', dest='history')
    parser.add_argument('--train', dest='train')
    parser.add_argument('--test', dest='test')
    parser.add_argument('--testRate', dest='testRate', type=float, default=0.2)
    args = parser.parse_args()
    run(args.history, args.train, args.test, args.testRate)
