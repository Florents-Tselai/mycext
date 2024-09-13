DUCKDB_VERSION = 1.1.0
PREFIX ?= $(shell pwd)/local
DUCKDB_BIN = $(PREFIX)/bin/duckdb

CC = gcc
CFLAGS = -Wall -Wextra -shared -Wunused-parameter -fPIC
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


UNAME_S := $(shell uname -s)
LIB_PATH = UNKNOWN_LIBRARY_PATH
ifeq ($(UNAME_S), Linux)
	LIB_PATH = LD_LIBRARY_PATH
else ifeq ($(UNAME_S), Darwin)
	LIB_PATH = DYLD_LIBRARY_PATH
endif

test:
	@export $(LIB_PATH)=$(PREFIX)/lib; \
	$(DUCKDB_BIN) -unsigned -c ".read test_$(EXTNAME).sql" --echo ./test.duckdb

install-duckdb:
	mkdir /tmp/duckdb && \
	cd /tmp/duckdb && \
	wget "https://github.com/duckdb/duckdb/archive/refs/tags/v$(DUCKDB_VERSION).tar.gz" && \
	tar xzf v$(DUCKDB_VERSION).tar.gz && \
	cd duckdb-$(DUCKDB_VERSION) && \
	cmake --install-prefix=$(PREFIX) . && \
	make -j4 all && \
	make install && \
	rm -rf /tmp/duckdb

clean:
	rm -f $(OBJS) $(TARGET)
	rm test.duckdb

.PHONY: all clean install test install-duckdb
