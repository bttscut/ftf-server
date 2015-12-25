-module(cfgloader).
-export([start/0]).

start() ->
    {ok, Bin} = file:read_file("./proto/protolist.json"),
    {ProtoList} = jiffy:decode(Bin),
    ets:new(plist, [set, named_table]),
    lists:foreach(fun(V) -> ets:insert(plist, V) end, ProtoList),
    log:info("cfg load finished!"),
    receive
    after infinity ->
            ok
    end.
