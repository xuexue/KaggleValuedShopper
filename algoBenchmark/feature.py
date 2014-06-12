'''Generate features CSV for the appropriate data'''
import argparse
import time
from collections import defaultdict

DATEFORMAT = "%Y-%m-%d"

# GLOBALS
keys_tmpl = ['has_bought_%s', 'has_bought_%s_a', 'has_bought_%s_q',
        'has_bought_%s_30', 'has_bought_%s_60', 'has_bought_%s_90',
        'has_bought_%s_120', 'has_bought_%s_150', 'has_bought_%s_180']
keys = [x % y for x in keys_tmpl
        for y in ['company', 'category', 'brand']
        ] + ['total_spend', 'total_quantity', 'total_purchases',
                'offer_value',
                'has_never_bought_company',
                'has_never_bought_brand',
                'has_never_bought_category',
                'has_bought_company_brand',
                'has_bought_category_brand',
                'has_bought_category_company']

def fill_derived_features(ftrs):
    '''Helper function to add a couple of derived features'''
    ftrs['has_never_bought_company'] = int(ftrs['has_bought_company'] == 0)
    ftrs['has_never_bought_brand'] = int(ftrs['has_bought_brand'] == 0)
    ftrs['has_never_bought_category'] = int(ftrs['has_bought_category'] == 0)

    ftrs['has_bought_company_brand'] = int(ftrs['has_bought_company'] > 0 and ftrs['has_bought_brand'] > 0)
    ftrs['has_bought_category_brand'] = int(ftrs['has_bought_category'] > 0 and ftrs['has_bought_brand'] > 0)
    ftrs['has_bought_category_company'] = int(ftrs['has_bought_category'] > 0 and ftrs['has_bought_company'] > 0)

def write_data(outfile, id, ftrs, historydict, HAS_REAL_VALUE=True):
    '''Helper function to write the row to output file'''
    features = [ftrs[k] for k in keys]
    towrite = [id] + features
    if HAS_REAL_VALUE:
        towrite += historydict[id]['repeater']
    outfile.write(','.join(str(x) for x in towrite) + '\n')

def run(offers, history, transactions, out):
    HAS_REAL_VALUE = False

    print('read offers into memory')
    offersdict = {}
    offersfile = open(offers)
    offersfile.next() # header
    for line in offersfile:
        line = line.strip().split(",")
        offersdict[line[0]] = {
                'category': line[1],
                'company': line[3],
                'offervalue': line[4],
                'brand': line[5],
                }

    print('read training data info into memory')
    historydict = {}
    historyfile = open(history)
    header = historyfile.next()
    HAS_REAL_VALUE = ('repeater' in header.strip().split(','))
    for line in historyfile:
        line = line.strip().split(',')
        historydict[line[0]] = {
                'offer': line[2],
                'offerdate': time.mktime(time.strptime(line[4], DATEFORMAT))
                }

    print('set up the transaction file %s and output file %s' % (transactions, out))
    headers = ['id'] + keys
    if HAS_REAL_VALUE:
        headers += ['repeater']
    outfile = open(out, 'w')
    outfile.write(','.join(headers) + '\n')

    print('go through the transaction file and populate features')
    transactfile = open(transactions)
    transactfile.next() # header
    lastID = None
    i = 0
    ftrs = defaultdict(lambda: 0) # all default values happen to be zero
    for line in transactfile:
        line = line.strip().split(',')
        id = line[0]
        event = {
                'id': id,
                'date': line[6],
                'category': line[3],
                'company': line[4],
                'brand': line[5],
                'purchasequantity': float(line[-2]),
                'purchaseamount': float(line[-1])
        }

        if id != lastID and lastID is not None:
            fill_derived_features(ftrs)
            write_data(outfile, lastID, ftrs, historydict, HAS_REAL_VALUE)
            ftrs = defaultdict(lambda: 0) # all default values happen to be zero
            i += 1
            if i % 1000 == 0:
                print i
            if i == 5000:
                break
        lastID = id

        offerid = historydict[id]['offer']
        curroffer = offersdict[offerid]

        dt = time.mktime(time.strptime(event['date'], DATEFORMAT))
        datediff = (historydict[id]['offerdate'] - dt) / (60*60*24)

        for col in ['company', 'category', 'brand']:
            if curroffer[col] == event[col]:
                ftrs['has_bought_%s' % col] += 1
                ftrs['has_bought_%s_a' % col] += event['purchaseamount']
                ftrs['has_bought_%s_q' % col] += event['purchasequantity']
                if datediff < 30:
                    ftrs['has_bought_%s_30' % col] += 1
                if datediff < 60:
                    ftrs['has_bought_%s_60' % col] += 1
                if datediff < 90:
                    ftrs['has_bought_%s_90' % col] += 1
                if datediff < 120:
                    ftrs['has_bought_%s_120' % col] += 1
                if datediff < 150:
                    ftrs['has_bought_%s_150' % col] += 1
                if datediff < 180:
                    ftrs['has_bought_%s_180' % col] += 1
        ftrs['total_spend'] += event['purchaseamount']
        ftrs['total_quantity'] += event['purchasequantity']
        ftrs['total_purchases'] += 1
        ftrs['offer_value'] = curroffer['offervalue'] # kind of repeat

    # write the last row
    fill_derived_features(ftrs)
    write_data(outfile, id, ftrs, historydict, HAS_REAL_VALUE)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Test the result of an algo')
    parser.add_argument('--offers', dest='offers', default='../data/offers')
    parser.add_argument('--history', dest='history')
    parser.add_argument('--transactions', dest='transactions')
    parser.add_argument('--out', dest='out', default=None)
    args = parser.parse_args()

    #import cProfile
    run(args.offers, args.history, args.transactions, args.out)
