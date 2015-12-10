-module(player_agent).
-export([start/1]).

start(Socket) ->
    loop(Socket).

loop(Socket) ->
    receive
        {tcp, Socket, SocketData} ->
            {package, ProtoId, ProtoData} = package_pb:decode(package, SocketData),
            [ModName, ProtoName] = find_proto(ProtoId),
            Request = apply(list_to_atom(ModName ++ "_pb"), decode, [list_to_atom(ProtoName), ProtoData]),
            Resp = apply(protos, list_to_atom(ProtoName), [Request]),
            RespEncoded = iolist_to_binary(apply(list_to_atom(ModName ++ "_pb"), encode, [Resp])),
            case gen_tcp:send(Socket, RespEncoded) of
                ok -> ok;
                {error, Reason} ->
                    io:format("send to client error:~p~n", [Reason])
            end,
            
            loop(Socket);
        {tcp_closed, Socket} ->
            io:format("recv socket closed~n")
    end.

-spec find_proto(Id :: non_neg_integer()) -> [nonempty_string()].
find_proto(Id) ->
    [{_, BinName}] = ets:lookup(protolist, integer_to_binary(Id)),
    StrName = string:to_lower(atom_to_list(binary_to_atom(BinName, utf8))),
    string:tokens(StrName, ".").
 
