'''Generate features CSV for the appropriate data'''
import random
import argparse
import dateutil.parser
import csv
import Queue
import threading
from collections import defaultdict

# GLOBALS
keys_tmpl = ['has_bought_%s', 'has_bought_%s_a', 'has_bought_%s_q',
        'has_bought_%s_30', 'has_bought_%s_60', 'has_bought_%s_90',
        'has_bought_%s_120', 'has_bought_%s_150', 'has_bought_%s_180']
keys = [x % y for x in keys_tmpl
        for y in ['company', 'category', 'brand']
        ] + ['total_spend', 'total_quantity', 'total_purchases',
                'offer_value', 'has_never_bought_company',
                'has_never_bought_brand',
                'has_never_bought_category',
                'has_never_bought_companY_brand',
                'has_never_bought_category_brand',
                'has_never_bought_category_company']

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
    outfile.writerow(towrite)

def runOneFile(transactions, out, historydict, offersdict, HAS_REAL_VALUE=True):
    print('set up the transaction file %s and output file %s' % (transactions, out))
    headers = ['id'] + keys
    if HAS_REAL_VALUE:
        headers += ['repeater']
    outfile = csv.writer(open(out, 'w'))
    outfile.writerow(headers)

    print('define helper functions')

    print('go through the transaction file and populate features')
    transactfile = csv.DictReader(open(transactions))
    lastID = None
    i = 0
    ftrs = defaultdict(lambda: 0) # all default values happen to be zero
    for event in transactfile:
        id = event['id']

        if id != lastID and lastID is not None:
            fill_derived_features(ftrs)
            write_data(outfile, lastID, ftrs, historydict, HAS_REAL_VALUE)
            ftrs = defaultdict(lambda: 0) # all default values happen to be zero
            i += 1
            if i % 1000 == 0:
                print i
        lastID = id

        offerid = historydict[id]['offer']
        curroffer = offersdict[offerid]

        datediff = historydict[id]['offerdate'] - dateutil.parser.parse(event['date'])
        datediff = datediff.days

        for col in ['company', 'category', 'brand']:
            if curroffer[col] == event[col]:
                ftrs['has_bought_%s' % col] += 1
                ftrs['has_bought_%s_a' % col] += float(event['purchaseamount'])
                ftrs['has_bought_%s_q' % col] += float(event['purchasequantity'])
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
        ftrs['total_spend'] += float(event['purchaseamount'])
        ftrs['total_quantity'] += float(event['purchasequantity'])
        ftrs['total_purchases'] += 1
        ftrs['offer_value'] = curroffer['offervalue'] # kind of repeat

    # write the last row
    fill_derived_features(ftrs)
    write_data(outfile, id, ftrs, historydict, HAS_REAL_VALUE)

def run(offers, history, transactions, out):
    HAS_REAL_VALUE = False

    print('read offers into memory')
    offersdict = {}
    offersfile = csv.DictReader(open(offers))
    for item in offersfile:
        offersdict[item['offer']] = item

    print('read training data info into memory')
    historydict = {}
    historyfile = csv.DictReader(open(history))
    HAS_REAL_VALUE = ('repeater' in historyfile.fieldnames)
    for item in historyfile:
        item['offerdate'] = dateutil.parser.parse(item['offerdate'])
        historydict[item['id']] = item

    q = Queue.Queue(maxsize=1000)

    print('BEGIN!')
    def worker():
        id = hash(random.random())
        out = '_tmp_%d' % id
        headers = ['id'] + keys
        if HAS_REAL_VALUE:
            headers += ['repeater']
        outfile = csv.writer(open(out, 'w'))
        outfile.writerow(headers)

        while True:
            events = q.get()
            ftrs = defaultdict(lambda: 0) # all default values happen to be zero
            for event in events:
                id = event['id']
                offerid = historydict[id]['offer']
                curroffer = offersdict[offerid]
                datediff = historydict[id]['offerdate'] - dateutil.parser.parse(event['date'])
                datediff = datediff.days
                for col in ['company', 'category', 'brand']:
                    if curroffer[col] == event[col]:
                        ftrs['has_bought_%s' % col] += 1
                        ftrs['has_bought_%s_a' % col] += float(event['purchaseamount'])
                        ftrs['has_bought_%s_q' % col] += float(event['purchasequantity'])
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
                ftrs['total_spend'] += float(event['purchaseamount'])
                ftrs['total_quantity'] += float(event['purchasequantity'])
                ftrs['total_purchases'] += 1
                ftrs['offer_value'] = curroffer['offervalue'] # kind of repeat
            fill_derived_features(ftrs)
            write_data(outfile, id, ftrs, historydict, HAS_REAL_VALUE)
            q.task_done()

    for i in range(4):
        t = threading.Thread(target=worker)
        t.daemon = True
        t.start()

    transactfile = csv.DictReader(open(transactions))
    events = []
    lastID = None
    for event in transactfile:
        id = event['id']
        if id != lastID and lastID is not None:
            q.put(events)
            events = []
        lastID = id
        events.append(event)
    events.append(event)
    q.join()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Test the result of an algo')
    parser.add_argument('--offers', dest='offers', default='../data/offers')
    parser.add_argument('--history', dest='history')
    parser.add_argument('--transactions', dest='transactions')
    parser.add_argument('--out', dest='out', default=None)
    args = parser.parse_args()

    run(args.offers, args.history, args.transactions, args.out)
