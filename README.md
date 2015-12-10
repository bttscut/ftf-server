# ftf-server
rts-like game server base on Erlang/OTP 18.1.

### Dependencies
- [basho/erlang_protobuffs](https://github.com/basho/erlang_protobuffs) - Erlang google protocol buffer implementation.

- [davisp/jiffy](https://github.com/davisp/jiffy) - JSON NIFs for Erlang.

### Build & Run
	git clone https://github.com/bttscut/ftf-server.git
    make
    ./run.sh
    
### Instructions
Fill your own functions in ```src/protos.erl``` coresponding the definition in ```protos\*.proto``` to expend.
