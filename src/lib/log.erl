-module(log).
-export([info/1, info/2, error/1, error/2, debug/1, debug/2]).
-import(string, [concat/2]).
-compile({no_auto_import,[error/2]}).

debug(Msg) ->
    debug("~p", [Msg]).
debug(Fmt, Args) ->
    io:format(lists:concat(["DEBUG: ", Fmt, "~n"]), Args).

info(Msg) ->
    info("~p", [Msg]).
info(Fmt, Args) ->
    io:format(lists:concat(["INFO: ", Fmt, "~n"]), Args).

error(Msg) ->
    error("~p", [Msg]).
error(Fmt, Args) ->
    io:format(lists:concat(["ERROR: ", Fmt, "~n"]), Args).


