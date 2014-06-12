interm/train interm/test: data/trainHistory
	python splitTraining.py --history=data/trainHistory --train=interm/_train --test=interm/_test
	mv interm/_train interm/train
	mv interm/_test interm/test

interm/transact_train: interm/train data/transactions
	python extractTransaction.py --history=interm/train --transactions=data/transactions --out=interm/_transact_train
	mv interm/_transact_train interm/transact_train

#interm/transact_train_shard_0: interm/transact_train
#	python shard.py --input=interm/transact_train --id=id --output=interm/transact_train_shard --shards=32

interm/transact_test: interm/test data/transactions
	python extractTransaction.py --history=interm/test --transactions=data/transactions --out=interm/_transact_test
	mv interm/_transact_test interm/transact_test

interm/transact_submit: data/testHistory data/transactions
	python extractTransaction.py --history=data/testHistory --transactions=data/transactions --out=interm/_transact_submit
	mv interm/_transact_submit interm/transact_submit

all: interm/train interm/test interm/transact_train interm/transact_test interm/transact_submit
