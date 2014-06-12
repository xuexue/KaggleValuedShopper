'''Split a file into shards by some ID'''
import argparse
import csv

def run(input, id, output, shards=10):
    infile = csv.DictReader(open(input))
    keys = infile.fieldnames
    output = output + '_%d'
    outfiles = [csv.writer(open(output % i, 'w')) \
            for i in xrange(shards)]
    for outfile in outfiles:
        outfile.writerow(keys)
    for item in infile:
        shardID = hash(item[id]) % shards
        outfiles[shardID].writerow([item[k] for k in keys])

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Extract only useful transactions')
    parser.add_argument('--input', dest='input')
    parser.add_argument('--id', dest='id')
    parser.add_argument('--output', dest='output')
    parser.add_argument('--shards', dest='shards', type=int, default=10)
    args = parser.parse_args()
    run(args.input, args.id, args.output, args.shards)
