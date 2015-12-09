-module(server).
-export([start/0]).

start() ->
    io:format("server start!~n"),
    {ok, Listen} = gen_tcp:listen(3000, [binary, {packet, 0}, {reuseaddr, true}, {active, true}]),
    parallel_accept(Listen).

parallel_accept(Listen) ->
    case gen_tcp:accept(Listen) of
        {ok, Socket} ->
            debug_output("accept a client connect ~p~n", [Socket]),
            Pid = spawn(fun() -> loop(Socket) end),
            gen_tcp:controlling_process(Socket, Pid),
            parallel_accept(Listen);
        {error, closed} ->
            io:format("accept socket closed")
    end.

loop(Socket) ->
    receive
        {tcp, Socket, Data} ->
            io:format("recv ~p~n", [Data]),
            %{{ProtoId, Value}, Rest} = protobuffs:decode(Data, bytes),
            loop(Socket);
        {tcp_closed, Socket} ->
            io:format("recv socket closed~n")
    end.

debug_output(Format, Msg) ->
    io:format("[debug ~p]" ++ Format, lists:append([[self()], Msg])).
