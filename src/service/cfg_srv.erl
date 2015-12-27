-module(cfg_srv).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_link/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    {ok, Bin} = file:read_file("./proto/protolist.json"),
    {ProtoList} = jiffy:decode(Bin),
    ets:new(plist, [set, named_table]),
    lists:foreach(fun(V) -> ets:insert(plist, V) end, ProtoList),
    log:info("cfg load finished!"),
    {ok, 0}.
    
handle_call(Msg, From, State) ->
    {replay, "no reply", State}.

handle_cast(Msg, State) ->
    {noreply, State}.

handle_info(Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
