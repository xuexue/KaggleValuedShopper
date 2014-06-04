import argparse
import csv

def run(history, transactions, out):
    IDS = set()
    historyfile = csv.reader(open(history))
    historyfile.next() # header
    for line in historyfile:
        id = line[0]
        IDS.add(id)

    transactionsfile = csv.reader(open(transactions))
    outfile = csv.writer(open(out, 'w'))
    outfile.writerow(transactionsfile.next())
    for line in transactionsfile:
        if line[0] in IDS:
            outfile.writerow(line)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Extract only useful transactions')
    parser.add_argument('--history', dest='history')
    parser.add_argument('--transactions', dest='transactions')
    parser.add_argument('--out', dest='out')
    args = parser.parse_args()
    run(args.history, args.transactions, args.out)
