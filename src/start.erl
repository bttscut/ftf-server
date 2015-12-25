-module(start).
-export([start/0]).

start() ->
    spawn(cfgloader, start, []),
    application:start(fserver),
    log:info("------------server closed-------------").

