.phony: run clean

PRCSNG = ../processing-4.0.1/processing-java
OUT := out

run:
	mkdir -p out
	${PRCSNG} --sketch=${PWD} --output=${PWD}/out --force --run

clean:
	rm -rf out
