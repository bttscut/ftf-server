-module(start).
-export([start/0]).

start() ->
    application:start(fserver),
    log:info("------------server closed-------------").

