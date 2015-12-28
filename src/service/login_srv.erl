-module(login_srv).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_link/1]).
-include("include/client_srv.hrl").

start_link(Port) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, Port, []).

init(Port) ->
    %process_flag(trap_exit, true),
    gen_server:cast(?MODULE, {listen, Port}),
    log:info("~p start", [?MODULE]),
    {ok, 0}.
    
handle_call(Msg, From, State) ->
    log:error("~p error call from: ~p msg: ~p", [?MODULE, From, Msg]),
    {replay, "no reply", State}.

handle_cast({listen, Port}, State) ->
    log:info("begin listen: ~p...", [Port]),
    {ok, Listen} = gen_tcp:listen(Port, [binary, {active, false}, {packet, 2}, {reuseaddr, true}]),
    log:info("listen: ~p...", [Port]),
    accept(Listen),
    {noreply, State};
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

accept(Listen) ->
    log:info("accept start!"),
    case gen_tcp:accept(Listen) of
        {ok, Socket} ->
            log:info("accpeted: ~p...", [Socket]),
            %Pid = spawn(proto_launcher2, start, [Socket, {login_auth, 0}]),
            State = #csrv_state{proto = login_auth, mstate={Socket}},
            client_srv:start(Socket, State, [{interval, 1000}]);
        {error, Reason} ->
            log:info("accept err: ~p", Reason)
    end,
    accept(Listen).

