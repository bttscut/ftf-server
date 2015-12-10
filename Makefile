.PHONY: all clean

ROOT=$(CURDIR)
BUILD_DIR=$(ROOT)/build
BIN_DIR=$(ROOT)/bin
SOURCE_DIR=$(ROOT)/src
PROTOS_DIR=$(ROOT)/protos
INCLUDE_DIR=$(ROOT)/include

MODS=$(SOURCE_DIR)/gate \
	 $(SOURCE_DIR)/bootstrap \
	 $(SOURCE_DIR)/protos \
	 $(SOURCE_DIR)/player_agent
	 
PROTOS=$(SOURCE_DIR)/test.proto

all: build
build:
	-mkdir $(BUILD_DIR)
	-mkdir $(BIN_DIR)
	-mkdir $(INCLUDE_DIR)

all: protobuf
protobuf: 
	erlc -o $(BUILD_DIR) protos_compile.erl
	cp ./3rd/erlang_protobuffs/*.beam $(BUILD_DIR)/
	cp ./3rd/yamler/*.beam $(BUILD_DIR)/
	cp ./3rd/jiffy/*.beam $(BUILD_DIR)/
	cd $(PROTOS_DIR) && erl -noshell -pa $(BUILD_DIR) -eval 'protos_compile:compile_all(".")' -s init stop
	cp $(PROTOS_DIR)/*.beam $(BUILD_DIR)/ && rm $(PROTOS_DIR)/*.beam
	#-cp $(PROTOS_DIR)/*.erl $(SOURCE_DIR)/ && rm $(PROTOS_DIR)/*.erl
	cp $(PROTOS_DIR)/*.hrl $(INCLUDE_DIR)/ && rm $(PROTOS_DIR)/*.hrl
	
all:mods

mods: ${MODS:%=%.beam}

$(SOURCE_DIR)/gate.beam: $(SOURCE_DIR)/gate.erl
	erlc -o $(BIN_DIR) $^

$(SOURCE_DIR)/bootstrap.beam: $(SOURCE_DIR)/bootstrap.erl
	erlc -o $(BIN_DIR) $^

$(SOURCE_DIR)/protos.beam: $(SOURCE_DIR)/protos.erl
	erlc -o $(BIN_DIR) $^
	
$(SOURCE_DIR)/player_agent.beam: $(SOURCE_DIR)/player_agent.erl
	erlc -o $(BIN_DIR) $^

clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(BIN_DIR)
	rm -rf $(INCLUDE_DIR)
	rm -rf ./erl_crash.dump
