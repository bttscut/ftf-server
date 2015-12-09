-module(protos_compile).
-export([compile_all/1]).

compile_all(Dir) ->
    io:format("start compile ~p~n", [Dir]),
    case file:list_dir(Dir) of
        {ok, FileNames} ->
            [compile(Dir, File) || File <- FileNames, filename:extension(File) == ".proto"];
        {error, Reason} ->
            io:format("list dir ~p error ~p~n", [Dir, Reason])
    end.

compile(Dir, File) ->
    AbsFileName = filename:join(Dir, File),
    protobuffs_compile:scan_file(AbsFileName),
    protobuffs_compile:generate_source(AbsFileName),
    ok.
