-module(gate).
-export([start/0]).

start() ->
    %load protolist data and save to ets
    {ok, Bin} = file:read_file("./protos/protolist.json"),
    {ProtoList} = jiffy:decode(Bin),
    ets:new(protolist, [set, named_table]),
    lists:foreach(fun(Value) -> ets:insert(protolist, Value) end, ProtoList),

    %start to listen
    {ok, Listen} = gen_tcp:listen(3000, [binary, {packet, 0}, {reuseaddr, true}, {active, true}]),
    parallel_accept(Listen).

parallel_accept(Listen) ->
    case gen_tcp:accept(Listen) of
        {ok, Socket} ->
            %debug_output("accept a client connect ~p~n", [Socket]),
            Pid = spawn(player_agent, start, [Socket]),
            gen_tcp:controlling_process(Socket, Pid),
            parallel_accept(Listen);
        {error, closed} ->
            io:format("accept socket closed")
    end.

    
debug_output(Format, Msg) ->
    io:format("[debug ~p]" ++ Format, lists:append([[self()], Msg])).
