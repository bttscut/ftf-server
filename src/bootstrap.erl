-module(bootstrap).
-export([start/0]).


start() ->
    register(gate, spawn(gate, start, [])),
    io:format("server start!~n"),
    receive
        {quit} ->
            ok
    end.
