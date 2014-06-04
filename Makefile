interm/transact_train: data/trainHistory data/transactions
	python extractTransaction.py --history=data/trainHistory --transactions=data/transactions --out=interm/_transact_train
	mv interm/_transact_train interm/transact_train

interm/transact_test: data/testHistory data/transactions
	python extractTransaction.py --history=data/testHistory --transactions=data/transactions --out=interm/_transact_test
	mv interm/_transact_test interm/transact_test
