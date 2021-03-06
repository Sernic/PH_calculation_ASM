MAIN = build
GCC = gcc
FLAGS = -m32
SRC = controller.c pH_calculation.s
DST = controller

$(MAIN): $(DST)
controller: $(SRC)
	$(GCC) $(FLAGS) -o $(DST) $(SRC)
run:
	./$(DST) testin.txt testout.txt
clean:
	rm -f $(DST) core
