../target/resultRandomTest: ../interm/test
	python run.py --data=../interm/test --out=../target/resultRandomTest

all: ../target/resultRandomTest
	python ../roc.py  --data=../interm/test --out=../target/resultRandomTest

submission:
	echo "You're not serious..."
