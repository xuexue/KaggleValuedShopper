../target/resultRandom:
	python run.py --data=../data/trainHistory --out=../target/resultRandom

all: ../target/resultRandom
	python ../roc.py  --data=../data/trainHistory --out=../target/resultRandom
