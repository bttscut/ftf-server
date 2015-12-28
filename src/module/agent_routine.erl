-module(agent_routine).
-export([update/2]).

update(State, Intvl) ->
    log:debug(Intvl),
    State.
