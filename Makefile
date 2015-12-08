.PHONY: all clean

ROOT=$(CURDIR)
BUILD_DIR=$(ROOT)/build
BIN_DIR=$(ROOT)/bin
SOURCE_DIR=$(ROOT)/src
PROTOS_DIR=$(ROOT)/protos

MODS=$(SOURCE_DIR)/server
PROTOS=$(SOURCE_DIR)/test.proto

all: build
build:
	-mkdir $(BUILD_DIR)
	-mkdir $(BIN_DIR)

all: protobuf
protobuf: 
	erlc protos_compile.erl && mv protos_compile.beam ./build/protos_compile.beam
	cp ./3rd/erlang_protobuffs/*.beam ./build/
	cd $(PROTOS_DIR) && erl -noshell -pa $(BUILD_DIR) -eval 'protos_compile:compile_all(".")' -s init stop
	cp $(PROTOS_DIR)/*.beam $(BUILD_DIR)/ && rm $(PROTOS_DIR)/*.beam
	-cp $(PROTOS_DIR)/*.erl $(SOURCE_DIR)/ && rm $(PROTOS_DIR)/*.erl
	cp $(PROTOS_DIR)/*.hrl $(SOURCE_DIR)/protos && rm $(PROTOS_DIR)/*.hrl
	
all:mods

mods: ${MODS:%=%.beam}

$(SOURCE_DIR)/server.beam: $(SOURCE_DIR)/server.erl
	erlc -o $(BIN_DIR) $^

clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(BIN_DIR)
	rm -rf ./erl_crash.dump
