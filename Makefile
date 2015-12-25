.PHONY:all deps src proto clean init

all:deps src

deps:
	test -d deps || ./rebar get-deps

src:
	./rebar compile

run:
	make src && ./run.sh

init:
	test -d proto || svn co svn://203.195.235.217/ftf/common/proto

clean:
	rebar clean
