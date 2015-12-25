#!/bin/sh

erl -noshell -pa './deps/protobuffs/ebin' -pa './deps/jiffy/ebin' -pa './deps/meck/ebin' -pa './ebin' -s start
