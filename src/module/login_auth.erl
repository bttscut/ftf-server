-module(login_auth).
-export([login/2]).
-include("include/client_srv.hrl").
-include("include/login_pb.hrl").

login(P, State) ->
    log:info(P),
    log:info(P#login.account),
    log:info(P#login.passwd),
    AState = #csrv_state{proto=agent_proto, routine=agent_routine, mstate={}},
    {Socket} = State,
    if 
        true ->
            client_srv:start(Socket, AState, [{interval, 1000}]),
            gen_server:cast(self(), {stop, login_ok})
    end,
    {resp, #login_response{errcode=0}, State}.
    %{noresp, State}.
