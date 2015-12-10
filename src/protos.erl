-module(protos).
-compile(export_all).
-include("./include/test1_pb.hrl").
-include("./include/test2_pb.hrl").

test(Args) when is_record(Args, test) ->
    io:format("id:~p,msg:~p~n", [Args#test.id, Args#test.msg]),
    #test_response{ok=0}.
    
test_add(Args) when is_record(Args, test_add) ->
    Sum = Args#test_add.a + Args#test_add.b,
    io:format("~p + ~p = ~p~n", [Args#test_add.a, Args#test_add.b, Sum]),
    #test_add_response{sum=Sum}.


test_sub(Args) when is_record(Args, test_sub) ->
    Diff = Args#test_sub.a - Args#test_sub.b,
    io:format("~p - ~p = ~p~n", [Args#test_sub.a, Args#test_sub.b, Diff]),
    #test_sub_response{diff=Diff}. 
