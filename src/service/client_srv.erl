-module(client_srv).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start/3]).
-include("include/base_pb.hrl").
-include("include/client_srv.hrl").

start(Socket, State, Opts) ->
    gen_server:start(?MODULE, {Socket, State, Opts}, []).

init({Socket, State, Opts}) ->
    gen_server:cast(self(), {start, Socket, Opts}),
    log:info("~p start", [?MODULE]),
    {ok, State}.
    
handle_call(Msg, From, State) ->
    log:error("~p error call from: ~p msg: ~p", [?MODULE, From, Msg]),
    RMod = State#csrv_state.routine,
    case RMod of
        undefined -> 
            {replay, "no reply", State};
        _ -> 
            {ok, Ret, NMState} = RMod:update(State#csrv_state.mstate),
            {replay, Ret, State#csrv_state{mstate=NMState}}
    end.

handle_cast({start, Socket, Opts}, State) ->
    Intvl = case lists:keyfind(interval, 1, Opts) of
        {interval, I} -> I;
        false -> 0
    end,
    gen_server:cast(self(), {loop, Socket, os:system_time(milli_seconds), Intvl}),
    {noreply, State};
handle_cast({loop, Socket, LastTs, Interval}, State) ->
    NewMState = loop(Socket, State, LastTs, Interval),
    {noreply, NewMState};

handle_cast(Msg, State) ->
    log:error("~p error cast msg:~p", [?MODULE, Msg]),
    {noreply, State}.
    
handle_info(Info, State) ->
    log:error("~p error info: ~p", [?MODULE, Info]),
    {noreply, State}.

terminate(_Reason, _State) ->
    log:error("terminate"),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

loop(Socket, #csrv_state{proto=PMod,routine=RMod,mstate=MState}=State, LastTs, Interval) ->
    %log:debug("------------~p", [LastTs]),
    NextTs = LastTs + Interval,
    TimeOut = if
                Interval > 0 -> 0;
                true -> infinity
            end,
    NewMState2 = case gen_tcp:recv(Socket, 0, TimeOut) of
        {ok, SockData} ->
            log:info("socket:~p receive data~p", [Socket, SockData]),
            {pack, Id, Session, Data} = base_pb:decode_pack(SockData),
            [FileName, MsgName] = find_proto(Id),
            ModAtom = list_to_atom(FileName ++ "_pb"),
            MsgAtom = list_to_atom(MsgName),
            Req = apply(ModAtom, decode, [MsgAtom, Data]),
            case apply(PMod, MsgAtom, [Req, MState]) of
                {resp, Resp, NewMState} ->
                    RetData = iolist_to_binary(apply(ModAtom, encode, [Resp])),
                    RetPack = base_pb:encode_pack(#pack{session=Session, data=RetData}),
                    case gen_tcp:send(Socket, RetPack) of
                        ok ->
                            log:debug("send sock:~p data:~p", [Socket, RetPack]);
                        {error, Reason} ->
                            log:error("send error sock:~p reason:~p", [Socket, Reason])
                    end;
                {noresp, NewMState} -> ok
            end,
            NewMState;
        {error, closed} ->
            log:info("socket closed: ~p", [Socket]),
            exit(socket_closed);
        {error, timeout} ->
            MState;
        Err ->
            log:error("!!!!!!!!!!!!!!!!!!!~p", [Err]),
            exit(Err)
    end,
    NewMState3 = case RMod of
        undefined -> NewMState2;
        _ -> RMod:update(NewMState2)
    end,
    TimeDiff = NextTs - os:system_time(milli_seconds),
    %log:debug(TimeDiff),
    NewMState4 = if
        TimeDiff > 0 ->
            timer:apply_after(TimeDiff, gen_server, cast, [self(), {loop, Socket, NextTs, Interval}]),
            NewMState3;
        true ->
            loop(Socket, NewMState3, NextTs, Interval)
    end,
    State#csrv_state{mstate = NewMState4}.

find_proto(Id) ->
    [{_, Pname}] = ets:lookup(plist, integer_to_binary(Id)),
    string:tokens(binary_to_list(Pname), ".").

