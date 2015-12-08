#!/bin/bash

script=$1
if [ -z $script ];then
    script=server
fi

erl -noshell -pa ./bin -pa ./build -s $script start -s init stop
