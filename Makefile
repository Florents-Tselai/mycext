DUCKDB_VERSION = 1.1.0
PREFIX ?= $(shell pwd)/local
DUCKDB_BIN = $(PREFIX)/bin/duckdb

CC = gcc
CFLAGS = -Wall -Wextra -shared -Wunused-parameter
INCLUDES = -I$(PREFIX)/include
LDFLAGS = -L$(PREFIX)/lib
LIBS =  -lduckdb

EXTNAME = mycext

TARGET = $(EXTNAME).duckdb_extension
SRCS = $(wildcard *.c)
OBJS = $(SRCS:.c=.o)

all: $(TARGET)

%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

$(TARGET): $(OBJS)
	$(CC) $(INCLUDES) $(CFLAGS) $(LDFLAGS) $(LIBS) -o $(TARGET) $(OBJS)

clean:
	rm -f $(OBJS) $(TARGET)
	rm test.duckdb

test:
	export DYLD_LIBRARY_PATH=$(DUCKDB_BIN)/lib; \
	$(DUCKDB_BIN) -unsigned -c ".read test_$(EXTNAME).sql" --echo ./test.duckdb

.PHONY: all clean install test

dev: clean all test


install-duckdb:
	cd /tmp && \
	wget "https://github.com/duckdb/duckdb/archive/refs/tags/v$(DUCKDB_VERSION).tar.gz" && \
	tar xzf v$(DUCKDB_VERSION).tar.gz && \
	cd duckdb-$(DUCKDB_VERSION) && \
	cmake --install-prefix=$(PREFIX) . && \
	make -j4 all && \
	make install

.PHONY: install-duckdb