-module(agent_proto).
-export([loadrole/2, login/2]).
-include("include/login_pb.hrl").

loadrole(P, State) ->
    log:info(P),
    {noresp, State}.

login(P, State) ->
    log:info(?MODULE),
    log:info(P#login.account),
    log:info(P#login.passwd),
    {resp, #login_response{errcode=0}, State}.
