-module(login_auth).
-export([login/2]).
-include("include/login_pb.hrl").

login(P, Mod) ->
    log:info(P),
    log:info(P#login.account),
    log:info(P#login.passwd),
    {resp, #login_response{errcode=0}, Mod}.
    %{noresp, Mod}.
