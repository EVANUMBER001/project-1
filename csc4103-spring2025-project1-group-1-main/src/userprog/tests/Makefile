CC = gcc
CFLAGS = -Wall -g
LDFLAGS = -lm

SRC = ../process.c
OBJ = $(SRC:.c=.o)

TESTS = test_process.o
TEST_EXEC = test_process

all: $(TEST_EXEC)

$(TEST_EXEC): $(OBJ) $(TESTS)
	$(CC) -o $@ $^ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ) $(TESTS) $(TEST_EXEC)