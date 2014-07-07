'''Split a file into shards by some ID'''
import argparse

def run(input, output, shards=10):
    infile = open(input)
    output = output + '_%d'
    outfiles = [open(output % i, 'w') for i in xrange(shards)]

    header = infile.next()
    for outfile in outfiles:
        outfile.write(header)

    previous = None
    i = 0
    for line in infile:
        id = line.split(",")[0]
        if id != previous:
            i = (i + 1) % shards
            previous = id
        outfiles[i].write(line)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Extract only useful transactions')
    parser.add_argument('--input', dest='input')
    parser.add_argument('--output', dest='output')
    parser.add_argument('--shards', dest='shards', type=int, default=10)
    args = parser.parse_args()
    run(args.input, args.output, args.shards)
